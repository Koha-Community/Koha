# RELEASE NOTES FOR KOHA 23.11.07
25 Jul 2024

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.11.07 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.11.07.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.11.07 is a bugfix/maintenance release.

It includes 4 enhancements, 62 bugfixes with 4 security.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [37018](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37018) SQL injection using q under api/
- [37146](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37146) plugin_launcher.pl allows running of any Perl file on file system
- [37210](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37210) SQL injection in overdue.pl
- [37247](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37247) On subscriptions operation allowed without authentication

## Bugfixes

### About

#### Other bugs fixed

- [37003](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37003) Release team 24.11
  >This updates the About Koha > Koha team with the release team members for Koha 22.11.

### Acquisitions

#### Critical bugs fixed

- [34444](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34444) Statistic 1/2 not saving when updating fund after receipt

#### Other bugs fixed

- [30493](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30493) Pending archived suggestions appear on staff interface home page
- [34718](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34718) Input field in fund list (Select2) on receive is inactive
- [37071](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37071) Purchase suggestions from the patron account are not redirecting to the suggestion form
  >This fixes the "New purchase suggestion" link from a patron's purchase suggestion area. The link now takes you to the new purchase suggestion form, instead of the suggestions management page. (This is related to the CSRF changes added in Koha 24.05 to improve form security.)

### Architecture, internals, and plumbing

#### Other bugs fixed

- [35294](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35294) Typo in comment in C4 circulation: barocode
  >This fixes spelling errors in catalog code comments (barocode => barcode, and preproccess => preprocess).
- [36940](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36940) Resolve two Auth warnings when AutoLocation is enabled having a branch without branchip
- [37037](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37037) touch_all_biblios.pl triggers rebuilding holds for all affected records when RealTimeHoldsQueue is enabled

### Cataloging

#### Other bugs fixed

- [25387](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25387) Merging different authority types creates no warning
  >This improves merging authorities of different types so that:
  >
  >1. When selecting the reference record, the authority record number and type are displayed next to each record.
  >2. When merging authority records of different types:
  >   . the authority type is now displayed in the tab heading, and
  >   . a warning is also displayed "Multiple authority types are used. There may be a data loss while merging.".
  >
  >Previously, no warning was given when merging authority records with different types - this could result in undesirable outcomes, data loss, and extra work required to clean up.
- [36891](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36891) Restore returning 404 from svc/bib when the bib number doesn't exist

### Circulation

#### Critical bugs fixed

- [37031](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37031) Club enrollment doesn't complete in staff interface
  >This fixes a typo in the code that causes the enrollment of a patron in a club to fail.

#### Other bugs fixed

- [36459](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36459) Backdating checkouts on circ/circulation.pl not working properly
- [37014](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37014) "Item was not checked in" printed on next POST because of missing supplementary form
- [37345](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37345) Remember for session checkbox on checkout page not sticking
  >This fixes the date in the "Specify due date" field if "Remember for session" is ticked (when checking out items to a patron). The date was not being remembered, and you had to select it again.

### Command-line Utilities

#### Other bugs fixed

- [34077](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34077) writeoff_debts without --confirm doesn't show which accountline records it would have been written off

### Developer documentation

#### Other bugs fixed

- [37198](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37198) POD for GetPreparedLetter doesn't include 'objects'
  >This updates the GetPreparedLetter documentation for developers (it was not updated when changes were made in Bug 19966 - Add ability to pass objects directly to slips and notices).

### ERM

#### Other bugs fixed

- [36956](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36956) ERM eUsage reports: only the first 20 data providers are listed when creating a new report
- [37043](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37043) Counter registry has a new API base URL

### Fines and fees

#### Critical bugs fixed

- [28664](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28664) One should not be able to issue a refund against a VOID accountline
  >This fixes VOID transactions for patron accounting entries so that the 'Issue refund' button is not available.

### I18N/L10N

#### Critical bugs fixed

- [33237](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33237) If TranslateNotices is off, use the default language includes in slips
  >This patch set cleans up the way languages are chosen and used in includes when printing slips. Previously, if the system preference 'TranslateNotices' was turned off (meaning the patron had their language set to 'Default'), the includes texts would be in English, even if the library had written their notices in a different language e.g. French.
  >
  >With this patch set, the language used for includes will always match the language used for creating the notice itself, regardless of whether 'TranslateNotices' is turned on or off.
  >
  >This patch set also makes important changes to the logic used to set the language. With this patch, the notice will:
  >1. use patron's preferred language
  >2. if patron's preferred language is 'default', use the first language in 'language' system preference.
  >
  >This patch set also adds the display of 'Default language' to the language that will be marked as 'Default' in the notices editor tool so that the librarian writing a notice will know exactly which language will be used when printing slips.
  >
  >Please note that due to these changes it is no longer possible to print the slip in any installed language simply by switching the staff interface language before printing! Bug 36733 has been added as a follow-up for restoring this functionality.

#### Other bugs fixed

- [32313](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32313) Complete database column descriptions for cataloguing module in guided reports
  >This fixes some column descriptions used in guided reports. It:
  >- Adds missing descriptions for the items and biblioitems tables (used by the Circulation, Catalog, Acquisitions, and Serials modules)
  >- Updates some column descriptions to make them more consistent or clearer.

### ILL

#### Other bugs fixed

- [36894](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36894) Journal article request authors do not show in the ILL requests table
  >This fixes the table for interlibrary loan (ILL) requests so that it now displays authors for journal article requests.

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [36424](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36424) Database update 23.06.00.061 breaks due to syntax error
- [37106](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37106) Upgrade to 23.11.05.009 causes an error because Koha::installer::Output doesn't exist in 23.11.x

  **Sponsored by** *Catalyst*

### Label/patron card printing

#### Other bugs fixed

- [36819](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36819) Default layout data prints squished barcodes
  >This fixes the default label layouts value for the barcode width (Cataloging > Tools > Label creator > Manage > Layouts > choose a layout). It was incorrectly set to 0.080000 when it should have been 0.800000 - this was resulting is squished barcodes when printing.
  >
  >Note: For existing 23.11 installations, this updates the correct value for the barcode width (field scale_width) to 0.800000 IF it is 0.080000. If it is any other value, no change is made.

### Notices

#### Critical bugs fixed

- [37059](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37059) 'Insert' button is not working in notices and slips tool

#### Other bugs fixed

- [36741](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36741) AUTO_RENEWALS_DGST should skip auto_too_soon
  >This fixes the default AUTO_RENEWALS_DGST notice so that items where it is too soon to renew aren't included in the notice output to patrons when the automatic renewals cron job is run (based on the circulation rules settings). These items were previously included in the notice.
  >
  >NOTE: This notice is only updated for new installations. Existing installations should update this notice if they only want to show the actual items automatically renewed.
- [37036](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37036) Cannot access template toolkit branch variable in auto renewal notices

### OPAC

#### Other bugs fixed

- [29539](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29539) UNIMARC: authority number in $9 displays for thesaurus controlled fields instead of content of $a
  >This fixes the display of authority terms in the OPAC for UNIMARC systems. The authority record number was displaying instead of the term, depending on the order of the $9 and $a subfields (example for a 606 entry: if $a then $9, the authority number was displayed; if $9 then $a, the authority term was displayed).

  **Sponsored by** *National Library of Greece*
- [30372](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30372) Patron self registration: Extended patron attributes are emptied on submit when mandatory field isn't filled in
  >This fixes the patron self registration form when extended patron attributes are used. If a mandatory field wasn't filled in when submitting, the values entered into any extended patron attributes were lost and needed re-entering.
- [36983](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36983) B_address_2 field is required even when not set to be required

### Patrons

#### Other bugs fixed

- [25520](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25520) Change wording on SMS phone number set up
  >This fixes the hint when entering an SMS number on the OPAC messaging settings page - it is now the same as the staff interface patron hint.

### REST API

#### Other bugs fixed

- [37021](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37021) REST API: Holds endpoint handles item_id as string in GET call

### SIP2

#### Other bugs fixed

- [36948](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36948) Adjust SIPconfig for log_file and IP version
- [37016](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37016) SIP2 renew shows old/wrong date due
  >Set correct due date in SIP2 renewal response message.

### Searching

#### Critical bugs fixed

- [35989](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35989) Searching Geographic authorities generates error

#### Other bugs fixed

- [33563](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33563) Document Elasticsearch secure mode
  >When using authentication with Elasticsearch/Opensearch, you must use HTTPS. This change adds some comments in koha-conf.xml to show how to do configure Koha to use authentication and HTTPS for ES/OS.

### Searching - Elasticsearch

#### Other bugs fixed

- [36982](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36982) Collections facet does not get alphabetized based on collection descriptions
  >This fixes the display of the 'Collections' facet for search results in the staff interface and OPAC when using Elasticsearch and Open Search. Values for the facet are now sorted alphabetically using the CCODE authorized values' descriptions, instead of the authorized values' codes.

### Self checkout

#### Other bugs fixed

- [35869](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35869) Dismissing an OPAC message from SCO logs the user out
- [36679](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36679) Anonymous patron is not blocked from checkout via self check
  >This fixes the web-based self-checkout system to prevent the AnonymousPatron from checking out items.
- [37026](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37026) Switching tabs in the sco_main page ( Checkouts, Holds, Charges ) creates a JS error
- [37044](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37044) OPAC message from SCO missing library branch
  >This fixes the self checkout "Messages for you" section for a patron so that any OPAC messages added by library staff now include the library name. Previously, "Written on DD/MM/YYYY by " was displayed after the message without including the library name.

### Serials

#### Critical bugs fixed

- [37183](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37183) Serials batch edit changes the expiration date to TODAY
  >This fixes batch editing of serials and the expiration date. Before this patch, if no date was entered in the expiration date field, it was changed to the current date when the batch edit form was saved. This caused the expiration date to change to the current date for all serials in the batch edit.

### Staff interface

#### Other bugs fixed

- [36930](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36930) Item search gives irrelevant results when using 2+ added filter criteria

### System Administration

#### Other bugs fixed

- [36527](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36527) Patron category or item type not changing when editing another circulation rule
- [37157](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37157) Error 500 when loading identity provider list
  >This fixes the listing of identity providers (Administration > Additional parameters > Identity providers) when special characters are used in the configuration and mapping fields (such as "scope": "élève"). Previously, using special characters in these fields caused a 500 error when viewing the Administration > Identity providers page.
- [37163](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37163) Fix the redirect after deleting a tag from an authority framework to load the right page

### Templates

#### Other bugs fixed

- [34573](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34573) Inconsistencies in acquisitions modify vendor title tag
  >This fixes page title, breadcrumb, and browser page title inconsistencies when adding and modifying vendor details in acquisitions.
- [34706](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34706) Capitalization: Cas login
  >This fixes a capitalization error. CAS is an abbreviation, and should be CAS on the login form (used when casAuthentication is enabled and configured).
- [35240](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35240) Missing form field ids in rotating collection edit form
  >This adds missing IDs to the rotating collections edit form (Tools > Rotating collections > edit a rotating collection (Actions > Edit)).
- [36338](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36338) Capitalization: Card number or Userid may already exist.
  >This fixes the text for the warning message in the web installer onboarding section when creating the Koha administrator patron - where the card number or username already exists. It now uses "username" instead of "Userid", and updates the surrounding text:
  >. Previous text: The patron has not been created! Card number or Userid may already exist.
  >. Updated text: The patron was not created! The card number or username already exists.
- [37162](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=37162) Remove dead confirmation code when deleting tags from authority frameworks

### Test Suite

#### Other bugs fixed

- [34838](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34838) The ILL module and tests generate warnings
- [36937](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36937) api/v1/password_validation.t generates warnings
  >This fixes the cause of a warning for the t/db_dependent/api/v1/password_validation.t tests (warning fixed: Use of uninitialized value $status in numeric eq (==)).
- [36938](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36938) Biblio.t generates warnings
- [36999](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36999) 00-strict.t fails to find koha_perl_deps.pl
  >This fixes the t/db_dependent/00-strict.t. The tests were failing as a file (koha_perl_deps.pl) was moved and is no longer required for these tests.

### Tools

#### Other bugs fixed

- [36128](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36128) Use of uninitialized value in string eq at /usr/share/koha/lib/C4/Overdues.pm
  >This fixes the following error message when running the overdues check cronjob on a Koha system without defined overdue rules:
  >
  >/etc/cron.daily/koha-common: Use of uninitialized value in string eq at /usr/share/koha/lib/C4/Overdues.pm line 686.

### Transaction logs

#### Other bugs fixed

- [30715](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30715) Terminology: Logs should use staff interface and not intranet for the interface
  >This fixes the log viewer so that 'Staff interface' is used instead of 'Intranet' for the filtering option and the value displayed in the log entries interface column.
  >
  >Note: This does not fix the underlying value recorded in the action_log table (these are added as 'intranet' to the interface column), or the values shown in CSV exports.

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [35536](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35536) Improve removal of Koha plugins in unit tests

### Authentication

#### Enhancements

- [36503](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36503) Add a plugin hook to modify patrons after authentication
  >This plugin hook allows to change patron data or define the patron based on the authenticated user.

  **Sponsored by** *Karlsruhe Institute of Technology (KIT)*

### OPAC

#### Enhancements

- [36141](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36141) Add classes to CAS text on OPAC login page
  >This enhancement adds classes to the CAS-related messages on the OPAC login page. This will make it easier for libraries to customize using CSS and JavaScript. The new classes are cas_invalid, cas_title, and cas_url. It also moves the invalid CAS login message to above the CAS login heading (the same as for the Shibboleth login).

### REST API

#### Enhancements

- [36565](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=36565) Fix API docs inconsistencies

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)
As of the date of these release notes, the Koha manual is available in the following languages:

- [Chinese (Traditional)](https://koha-community.org/manual/23.11/zh_Hant/html/) (76%)
- [English](https://koha-community.org/manual/23.11//html/) (100%)
- [English (USA)](https://koha-community.org/manual/23.11/en/html/)
- [French](https://koha-community.org/manual/23.11/fr/html/) (46%)
- [German](https://koha-community.org/manual/23.11/de/html/) (38%)
- [Greek](https://koha-community.org/manual/23.11//html/) (43%)
- [Hindi](https://koha-community.org/manual/23.11/hi/html/) (77%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:
<div style="column-count: 2;">

- Arabic (ar_ARAB) (99%)
- Armenian (hy_ARMN) (100%)
- Bulgarian (bg_CYRL) (100%)
- Chinese (Traditional) (91%)
- Czech (70%)
- Dutch (77%)
- English (100%)
- English (New Zealand) (64%)
- English (USA)
- Finnish (99%)
- French (99%)
- French (Canada) (97%)
- German (100%)
- German (Switzerland) (52%)
- Greek (58%)
- Hindi (99%)
- Italian (84%)
- Norwegian Bokmål (76%)
- Persian (fa_ARAB) (95%)
- Polish (99%)
- Portuguese (Brazil) (92%)
- Portuguese (Portugal) (88%)
- Russian (92%)
- Slovak (61%)
- Spanish (99%)
- Swedish (87%)
- Telugu (70%)
- Turkish (81%)
- Ukrainian (74%)
- hyw_ARMN (generated) (hyw_ARMN) (65%)
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

The release team for Koha 23.11.07 is


- Release Manager: Katrin Fischer

- Release Manager assistants:
  - Tomás Cohen Arazi
  - Martin Renvoize
  - Jonathan Druart

- QA Manager: Marcel de Rooy

- QA Team:
  - Marcel de Rooy
  - Julian Maurice
  - Lucas Gass
  - Victor Grousset
  - Kyle M Hall
  - Nick Clemens
  - Martin Renvoize
  - Tomás Cohen Arazi
  - Aleisha Amohia
  - Emily Lamancusa
  - David Cook
  - Jonathan Druart
  - Pedro Amorim

- Topic Experts:
  - UI Design -- Owen Leonard
  - Zebra -- Fridolin Somers
  - REST API -- Tomás Cohen Arazi
  - ERM -- Matt Blenkinsop
  - ILL -- Pedro Amorim
  - SIP2 -- Matthias Meusburger
  - CAS -- Matthias Meusburger

- Bug Wranglers:
  - Aleisha Amohia
  - Indranil Das Gupta

- Packaging Managers:
  - Mason James
  - Indranil Das Gupta
  - Tomás Cohen Arazi

- Documentation Manager: Aude Charillon

- Documentation Team:
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Philip Orr
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey

- Translation Manager: Jonathan Druart


- Wiki curators: 
  - Thomas Dukleth
  - Katrin Fischer

- Release Maintainers:
  - 23.11 -- Fridolin Somers
  - 23.05 -- Lucas Gass
  - 22.11 -- Frédéric Demians
  - 22.05 -- Danyon Sewell

- Release Maintainer assistants:
  - 22.05 -- Wainui Witika-Park

## Credits

We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 23.11.07
<div style="column-count: 2;">

- [Catalyst](https://www.catalyst.net.nz/products/library-management-koha)
- Karlsruhe Institute of Technology (KIT)
- National Library of Greece
</div>

We thank the following individuals who contributed patches to Koha 23.11.07
<div style="column-count: 2;">

- Aleisha Amohia (1)
- Pedro Amorim (7)
- Tomás Cohen Arazi (13)
- Matt Blenkinsop (7)
- Phan Tung Bui (1)
- Nick Clemens (7)
- David Cook (3)
- Chris Cormack (1)
- Jonathan Druart (2)
- Marion Durand (1)
- Katrin Fischer (3)
- Eric Garcia (1)
- Lucas Gass (5)
- Kyle M Hall (1)
- Andreas Jonsson (1)
- Janusz Kaczmarek (1)
- Denys Konovalov (1)
- Emily Lamancusa (1)
- Sam Lau (2)
- Laurae (1)
- Brendan Lawlor (2)
- Owen Leonard (2)
- Julian Maurice (3)
- David Nind (6)
- Andrew Nugged (1)
- Martin Renvoize (19)
- Phil Ringnalda (4)
- Marcel de Rooy (14)
- Caroline Cyr La Rose (2)
- Fridolin Somers (5)
- Lari Strand (2)
- Raphael Straub (3)
- Emmi Takkinen (1)
- George Veranis (1)
- Hammat Wele (5)
- Baptiste Wojtkowski (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.11.07
<div style="column-count: 2;">

- Athens County Public Libraries (2)
- [BibLibre](https://www.biblibre.com) (10)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (3)
- BigBallOfWax (1)
- [ByWater Solutions](https://bywatersolutions.com) (14)
- [Cape Libraries Automated Materials Sharing](https://info.clamsnet.org) (2)
- Catalyst Open Source Academy (1)
- Chetco Community Public Library (4)
- [Dataly Tech](https://dataly.gr) (1)
- David Nind (6)
- denyskon.de (1)
- Independant Individuals (5)
- Karlsruhe Institute of Technology (KIT) (3)
- Koha Community Developers (2)
- [Koha-Suomi Oy](https://koha-suomi.fi) (3)
- Kreablo AB (1)
- [Montgomery County Public Libraries](montgomerycountymd.gov) (1)
- [Prosentient Systems](https://www.prosentient.com.au) (3)
- [PTFS Europe](https://ptfs-europe.com) (33)
- Rijksmuseum, Netherlands (14)
- [Solutions inLibro inc](https://inlibro.com) (8)
- [Theke Solutions](https://theke.io) (13)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (3)
- Pedro Amorim (2)
- Tomás Cohen Arazi (8)
- Matt Blenkinsop (11)
- Nick Clemens (17)
- Chris Cormack (6)
- Jonathan Druart (13)
- Magnus Enger (1)
- Katrin Fischer (63)
- Eric Garcia (2)
- Lucas Gass (78)
- Kyle M Hall (9)
- Mason James (1)
- Jan Kissig (1)
- Thomas Klausner (1)
- Emily Lamancusa (7)
- Sam Lau (6)
- Owen Leonard (5)
- David Nind (28)
- Martin Renvoize (64)
- Marcel de Rooy (8)
- Michaela Sieber (1)
- Fridolin Somers (99)
- Tadeusz „tadzik” Sośnierz (2)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the main branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 Jul 2024 08:35:44.
