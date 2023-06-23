# RELEASE NOTES FOR KOHA 22.11.07
23 jun 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.07 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.07 is a bugfix/maintenance release.

It includes 5 enhancements, 77 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [33595](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33595) Bug 26628 broke authorization for tools start page

## Bugfixes

### About

#### Other bugs fixed

- [33877](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33877) Fix teams.yaml

### Acquisitions

#### Critical bugs fixed

- [34006](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34006) [22.11] Keep the current option for funds in receiving returns an error 500 or saves wrong fund

#### Other bugs fixed

- [33340](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33340) Correct formatting of English 1-page order PDF when the basket group covers multiple pages

  **Sponsored by** *Pymble Ladies' College*
  >If a basket group contains many order lines, this will ensure:
  > * The page number at the bottom of the first page is not obscured.
  > * The table of ordered items does not start half way down the second page.
- [33421](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33421) Filtering purchase suggestions by status does not work if All Libraries is selected
- [33663](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33663) Don't hide Suggestions link in side navigation when suggestion preference is disabled
- [33748](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33748) UI issue on addorderiso2709.pl page

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [33934](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33934) 'No encryption_key in koha-conf.xml' needs more detail
  >This fixes an issue that can cause upgrades to Koha 23.05 to fail with an error message that includes 'No encryption_key in koha-conf.xml'. It also requires the configuration entry in the instance koha-conf.xml to be something other than __ENCRYPTION_KEY__.
  >It is recommended that the key is generated using pwgen 32

#### Other bugs fixed

- [30649](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30649) Vendor EDI account passwords should be encrypted in the database
- [32060](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32060) Improve performance of Koha::Item->columns_to_str

  **Sponsored by** *Gothenburg University Library*
- [32464](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32464) Koha::Item->as_marc_field obsolete option mss
- [33489](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33489) The borrowers table should have indexes on default patron search fields
- [33718](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33718) _new_Zconn crashes on a bug in t::lib::Mocks::mock_config
- [33803](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33803) Some scripts contain info about tab width
- [33854](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33854) Typo in ImportBatchProfiles controller

### Authentication

#### Critical bugs fixed

- [33708](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33708) OAuth/OIDC authentication for the staff interface requires OPAC enabled
- [33815](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33815) Crash when librarian changes their own username in the staff interface

#### Other bugs fixed

- [33675](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33675) Add CSRF protection to OAuth/OIDC authentication
  >This development adds support for the `state` parameter generation and delivery when contacting IdPs. This is an optional but recommended opaque value in the OAuth2/OIDC specs that helps prevent CSRF attacks, but is also a requirement on some Identity Provider solutions.

### Cataloging

#### Other bugs fixed

- [32959](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32959) Item templates will apply the same barcode each time template is applied if autobarcode is enabled
- [33247](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33247) Deleted authority still on results list
- [33624](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33624) Using Browser "Back" button in Batch Record Modification causes biblio options to be displayed
- [33686](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33686) Update plugin unimarc_field_100.pl 'Script of title' with 2022 values

### Circulation

#### Critical bugs fixed

- [33362](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33362) Return claims can be un-resolvable if issue_id is set but no issue is found in issues or old_issues

#### Other bugs fixed

- [32878](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32878) Make it impossible to renew the item if it has active item level hold
- [33220](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33220) Recalls to pull should not show in transit or allocated items

  **Sponsored by** *Auckland University of Technology*
- [33838](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33838) Offline circulation interface error on return

### Command-line Utilities

#### Other bugs fixed

- [33717](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33717) Typo in search_for_data_inconsistencies.pl

### ERM

#### Other bugs fixed

- [33823](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33823) KohaTable vue component action buttons spacing differ from kohaTable

### Hold requests

#### Critical bugs fixed

- [33761](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33761) Holds queue is not selecting items with completed transfers

#### Other bugs fixed

- [33791](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33791) $hold->fill does not set itemnumber when checking out without confirming hold

### ILL

#### Critical bugs fixed

- [21983](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21983) Better handling of deleted biblios on ILL requests
- [33786](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33786) ILL requests table pagination in patron ILL history is transposing for different patrons
- [33873](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33873) ILL requests with linked biblio_id that no longer exists causes table to not render

#### Other bugs fixed

- [22440](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22440) Improve ILL page performance by moving to server side filtering
- [33762](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33762) Restore page-section in ILL

### Installation and upgrade (web-based installer)

#### Other bugs fixed

- [33935](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33935) Installer list deleted files which shows warning in the logs

### MARC Authority data support

#### Other bugs fixed

- [33138](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33138) Don't copy tag 147 to all MARC frameworks, since it should only be used in a separate NAME_EVENT framework

### MARC Bibliographic data support

#### Other bugs fixed

- [33865](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33865) JS error when importing a staged MARC record file

### OPAC

#### Other bugs fixed

- [29993](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29993) Syndetics cover images do not display in browse shelf when scrolling from the first page
- [33697](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33697) Remove deprecated RecordedBooks (rbdigital) integration
- [33767](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33767) Accessibility: The 'OPAC results' page contains semantically incorrect headings
- [33813](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33813) Accessibility: Lists button is not clearly identified
  >This enhancement adds an aria-label to the Lists button in the OPAC masthead. It is currently not descriptive enough and doesn't identify what is displayed when clicking the button.
- [33821](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33821) OPAC flatpickr no longer allows for direct input of date
- [33902](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33902) On opac-detail.tt the libraryInfoModal is outside of HTML tags
  >This moves the HTML for the pop-up window with the information for a library (where it exists) on the OPAC detail page inside the <html> tag so that it validates correctly. There is no change to the appearance or behavior of the page.

### Packaging

#### Other bugs fixed

- [33371](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33371) Add 'koha-common.service' systemd service

### Patrons

#### Critical bugs fixed

- [33829](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33829) Cannot add patron to patron list if PatronAutoComplete is off

#### Other bugs fixed

- [33875](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33875) Missing closing tag a in API key management page
- [33882](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33882) member.tt Date of birth column makes it difficult to hide the age hint

### Reports

#### Other bugs fixed

- [33713](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33713) Report batch operations should open in new tab
  >When using the batch operations from report results, the links to the batch tools will now open in a new tab instead of the same one, leaving the report results visible.
- [33792](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33792) reserves_stats.pl ignores filled holds without itemnumber

### SIP2

#### Other bugs fixed

- [33411](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33411) SIP2 includes other guarantees with the same guarantor when calculating against NoIssuesChargeGuarantees

### Searching

#### Critical bugs fixed

- [33297](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33297) Typo system preference RetainPatronSearchTerms in DB revs 220600044.pl

### Staff interface

#### Other bugs fixed

- [33463](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33463) 'Actions' column on plugins table should not be sortable
- [33788](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33788) Items tab shows all previous borrowers instead of 3

### System Administration

#### Other bugs fixed

- [32775](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32775) Ordering when there are multiple languages within a language group is wrong

  **Sponsored by** *Kinder library, New Zealand*
- [33787](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33787) Remove option to archive system debit types

### Templates

#### Other bugs fixed

- [33158](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33158) Use template wrapper for authorized values and item types administration tabs
- [33553](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33553) Unecessary GetCategories calls in template
- [33599](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33599) Use template wrapper for breadcrumbs: Various
- [33705](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33705) Tables have configure button even if they are not configurable
- [33707](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33707) News vs Quote of the day styling on staff interface main page
- [33721](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33721) Show inactive funds in invoice.tt out of order
- [33735](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33735) Misspelling in SMS provier
- [33779](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33779) Terminology: biblio record
- [33859](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33859) Use the phrase 'Identity providers' instead of 'Authentication providers'
- [33883](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33883) "Make sure to copy your API secret" message overlaps text
- [33891](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33891) Use template wrapper for tabs: OPAC advanced search
- [33892](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33892) Use template wrapper for tabs: OPAC authority detail

### Test Suite

#### Critical bugs fixed

- [33416](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33416) Agreements.ts is failing

#### Other bugs fixed

- [32648](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32648) Search.t is failing if run after Filter_MARC_ViewPolicy.t
- [33719](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33719) Search.t: too much noise about ContentWarningField
- [33743](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33743) xt/find-missing-filters.t parsing files outside of git repo
- [33777](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33777) Get Jenkins green again for Auth_with_shibboleth.t
- [33834](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33834) api/v1/ill_requests.t fails randomly

### Tools

#### Critical bugs fixed

- [26611](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26611) Required match checks don't work for authority records

  **Sponsored by** *Waikato Institute of Technology*
  >This fixes match checking for authorities when importing records, so that the required match checks are correctly applied. Previously, match checks for authority records did not work.

#### Other bugs fixed

- [31585](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31585) "ACQUISITION ORDER" action missing from log viewer search form
- [33010](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33010) CheckinSlip doesn't return checkins if checkout library and checkin library differ

  **Sponsored by** *Koha-Suomi Oy*

## Enhancements 

### ERM

#### Enhancements

- [32932](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32932) Re-structure Vue router-links to use "name" instead of urls

### OPAC

#### Enhancements

- [21330](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21330) Add XSLT for authority detail page in OPAC
  >This enhancement enables using custom XSLT stylesheets to display authority detail pages in the OPAC. 
  >
  >Enter a path to the custom XSLT file in the new system preference AuthorityXSLTOpacDetailsDisplay (or enter an external URL). Use placeholders for multiple custom style sheets for different languages ({langcode}) and authority types ({authtypecode}).

### Templates

#### Enhancements

- [32914](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32914) Use template wrapper for batch record deletion and modification templates
- [33524](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33524) Use template wrapper for tabs: Authority editor
- [33525](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33525) Use template wrapper for tabs: Basic MARC editor

## New system preferences

- AuthorityXSLTOpacDetailsDisplay

## Deleted system preferences

- RecordedBooksClientSecret
- RecordedBooksDomain
- RecordedBooksLibraryID

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (72.1%)
- Armenian (100%)
- Armenian (Classical) (64.9%)
- Bulgarian (91%)
- Chinese (Taiwan) (81.6%)
- Czech (62.4%)
- English (New Zealand) (68.3%)
- English (USA)
- English (United Kingdom) (99.9%)
- Finnish (95.5%)
- French (99.6%)
- French (Canada) (95.8%)
- German (100%)
- German (Switzerland) (50.3%)
- Greek (50.9%)
- Hindi (100%)
- Italian (92%)
- Nederlands-Nederland (Dutch-The Netherlands) (87.6%)
- Norwegian Bokmål (65%)
- Persian (70.3%)
- Polish (98.6%)
- Portuguese (89.4%)
- Portuguese (Brazil) (100%)
- Russian (93.7%)
- Slovak (61.9%)
- Spanish (100%)
- Swedish (76.9%)
- Telugu (77.3%)
- Turkish (87.3%)
- Ukrainian (78.1%)
</div>

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.11.07 is


- Release Manager: Tomás Cohen Arazi

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize

- QA Manager: Katrin Fischer

- QA Team:
  - Aleisha Amohia
  - Nick Clemens
  - David Cook
  - Jonathan Druart
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Andrii Nugged
  - Martin Renvoize
  - Marcel de Rooy
  - Petro Vashchuk

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Martin Renvoize
  - ERM -- Pedro Amorim
  - ILL -- Pedro Amorim

- Bug Wranglers:
  - Aleisha Amohia

- Packaging Manager: Mason James

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - Lucy Vaux-Harvey

- Translation Manager: Bernardo González Kriegel


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 23.05 -- Fridolin Somers
  - 22.11 -- PTFS Europe (Matt Blenkinsop, Pedro Amorim)
  - 22.05 -- Lucas Gass
  - 21.11 -- Danyon Sewell

- Release Maintainer assistants:
  - 21.11 -- Wainui Witika-Park

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 22.11.07
<div style="column-count: 2;">

- Auckland University of Technology
- Gothenburg University Library
- Kinder library, New Zealand
- [Koha-Suomi Oy](https://koha-suomi.fi)
- Pymble Ladies' College
- Waikato Institute of Technology
</div>

We thank the following individuals who contributed patches to Koha 22.11.07
<div style="column-count: 2;">

- Aleisha Amohia (2)
- Pedro Amorim (7)
- Tomás Cohen Arazi (24)
- Matt Blenkinsop (6)
- Jérémy Breuillard (1)
- Alex Buckley (4)
- Nick Clemens (8)
- David Cook (2)
- Jonathan Druart (20)
- Katrin Fischer (3)
- Lucas Gass (6)
- Thibaud Guillot (2)
- David Gustafsson (1)
- Kyle M Hall (4)
- Mason James (2)
- Owen Leonard (15)
- David Nind (1)
- Martin Renvoize (3)
- Phil Ringnalda (1)
- Marcel de Rooy (8)
- Caroline Cyr La Rose (1)
- Fridolin Somers (8)
- Emmi Takkinen (1)
- Koha translators (1)
- Petro Vashchuk (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.07
<div style="column-count: 2;">

- Athens County Public Libraries (15)
- BibLibre (11)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- ByWater-Solutions (18)
- Catalyst (4)
- Catalyst Open Source Academy (2)
- Chetco Community Public Library (1)
- David Nind (1)
- Göteborgs Universitet (1)
- Independant Individuals (1)
- Koha Community Developers (20)
- Koha-Suomi (1)
- KohaAloha (2)
- Prosentient Systems (2)
- PTFS-Europe (16)
- Rijksmuseum (8)
- Solutions inLibro inc (1)
- Theke Solutions (24)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Pedro Amorim (31)
- Tomás Cohen Arazi (96)
- Andrew Auld (2)
- Matt Blenkinsop (81)
- Nick Clemens (8)
- David Cook (12)
- Jonathan Druart (16)
- Laura Escamilla (1)
- Katrin Fischer (17)
- Andrew  Fuerste-Henry (1)
- Andrew Fuerste-Henry (2)
- Lucas Gass (7)
- Victor Grousset (5)
- Kyle M Hall (11)
- Barbara Johnson (4)
- Emily Lamancusa (2)
- Sam Lau (6)
- Owen Leonard (7)
- Agustín Moyano (1)
- David Nind (17)
- Andrew Nugged (1)
- Jacob O'Mara (2)
- Philip Orr (2)
- Martin Renvoize (19)
- Phil Ringnalda (2)
- Marcel de Rooy (19)
- Caroline Cyr La Rose (3)
- Michaela Sieber (2)
- Fridolin Somers (4)
- Thibault (3)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 22.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 jun 2023 15:16:49.
