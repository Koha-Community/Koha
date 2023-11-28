# RELEASE NOTES FOR KOHA 22.11.12
28 nov 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 22.11.12 can be downloaded from:

- [Download](http://download.koha-community.org/koha-22.11.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 22.11.12 is a bugfix/maintenance release.

It includes 15 enhancements, 83 bugfixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [35290](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35290) SQL Injection vulnerability in ysearch.pl
- [35291](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35291) File Upload vulnerability in upload-cover-image.pl

## Bugfixes

### About

#### Other bugs fixed

- [34424](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34424) Update release team on about page for new QA team member
- [34800](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34800) Update contributor openhub links
- [35033](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35033) Add a validation for biblioitems in about/system information

### Acquisitions

#### Other bugs fixed

- [22712](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22712) Funds from inactive budgets appear on Item details if using MarcItemFieldstoOrder
- [26994](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26994) Display list of names in alphabetical order when using the Suggestion information filter in Suggestions management
- [34375](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34375) Shipping fund in an invoice defaults to the first fund from the list rather than 'no fund' after receiving
- [35012](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35012) Framework item plugins fire twice on Acquisition item blocks

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [32305](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32305) Background worker doesn't check job status when received from rabbitmq
- [34204](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34204) Koha user needs to be able to login
- [34731](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34731) C4::Letters::SendQueuedMessages can be triggered with an undef message_id
  >This fixes an issue where generating a notice that is undefined (for example, where it is empty) will trigger the sending of any pending messages, even though the message queue cronjob isn't run. This can cause an issue for libraries that expect emails and SMS messages to be processed at specific times.
- [34959](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34959) Translator tool generates too many changes
- [35111](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35111) Background jobs worker crashes on SIGPIPE when database connection lost in Ubuntu 22.04
- [35199](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35199) Fix error handling in http-client.js

#### Other bugs fixed

- [32379](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32379) CRASH: Can't call method "itemlost" on an undefined value
- [34271](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34271) Remove a few Logger statements from REST API
- [34990](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34990) Backgroundjob->enqueue does not send persistent header
- [35000](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35000) OPACMandatoryHoldDates does not work well with flatpickr
- [35024](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35024) Do not wrap PO files
- [35064](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35064) Syntax error in db_revs/220600072.pl
- [35173](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35173) Call concat correctly for EDI SFTP Transport errors
- [35278](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35278) CGI::param called in list context from /usr/share/koha/admin/columns_settings.pl line 76
- [35298](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35298) Flatpickr makes focus handler in dateaccessioned plugin useless

### Authentication

#### Other bugs fixed

- [31393](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31393) Koha::Config->read_from_file incorrectly parses elements with 1 attribute named" content" (Shibboleth config)

### Cataloging

#### Critical bugs fixed

- [34993](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34993) Framework doesn't load defaults in existing records or duplicate as new
- [35343](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35343) record method, required for bug 26611, missing from Koha::Authority

#### Other bugs fixed

- [32853](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32853) Fix cataloguing/value_builder/unimarc_field_125.pl
- [32856](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32856) Fix cataloguing/value_builder/unimarc_field_126.pl
- [34171](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34171) item_barcode_transform does not work when moving items
- [34966](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34966) Terminology: Add item form - "Add & duplicate" should be "Add and duplicate"
  >This updates the add item form in the staff interface to
  >change the 'Add & duplicate' button to 'Add and duplicate'. (As per the terminology guidelines https://wiki.koha-community.org/wiki/Terminology)
- [35101](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35101) Clicking the barcode.pl plugin causes screen to jump back to top
- [35245](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35245) Incorrect select2 width when cataloging authorities

### Circulation

#### Critical bugs fixed

- [17798](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17798) Checking out an item on hold for another patron prints a slip but does not update hold
- [27249](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27249) Using the calendar to 'close' a library can create an infinite loop during renewals
- [35295](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35295) No hold modal when checking in an item of a held record

#### Other bugs fixed

- [33164](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33164) Return claim message shows intermittently when BlockReturnOfLostItems enabled

  **Sponsored by** *Pymble Ladies' College*
- [34704](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34704) Print templates are formatted incorrectly
  >The patch removes the automated additional of html linebreak markup to print notices when using --html.
  >
  >If you are using this flag with gather_print_notices.pl you may need to revisit your notice templates to ensure they are properly marked up as expected for html notices. If you are using non-html notices then they should remain as before.
- [34910](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34910) Do not allow checkout for anonymous patron

### Command-line Utilities

#### Other bugs fixed

- [35141](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35141) Prevent link_bibs_to_authorities from dying on search error

### ERM

#### Critical bugs fixed

- [33606](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33606) Access to ERM requires parameters => 'manage_sysprefs'

### Hold requests

#### Other bugs fixed

- [34678](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34678) Concurrent changes to the holds can fail due to primary key constraints
- [34901](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34901) Item-level holds can show inaccurate transit status on the patron details page
- [35003](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35003) Holds with cancellation requests table on waitingreserves.tt does not filter by branch
- [35069](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35069) Items needed column on circ/reserveratios.pl does not sort properly

### I18N/L10N

#### Other bugs fixed

- [32312](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32312) Complete database column descriptions for circulation module in guided reports
  >This adds and clarifies database column descriptions shown for the statistics table when creating a guided report for the circulation module. Previously, some columns didn't have a description or were ambiguous.

### Installation and upgrade (command-line installer)

#### Critical bugs fixed

- [34881](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34881) Database update for bug 28854 isn't fully idempotent

#### Other bugs fixed

- [35180](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35180) Fix typo in deletedbiblioitems.publishercode comment in kohastructure.sql

### Installation and upgrade (web-based installer)

#### Critical bugs fixed

- [34520](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34520) Database update 22.06.00.078 breaks update process

### MARC Authority data support

#### Other bugs fixed

- [30024](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=30024) link_bibs_to_authorities.pl relies on CatalogModuleRelink

### Notices

#### Other bugs fixed

- [35185](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35185) Remove is_html flag from sample notices for text notices
- [35186](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35186) Remove html tags from sample notices
  >This removes unnecessary <html></html> tags in two email notices:
  >* PASSWORD_RESET
  >* STAFF_PASSWORD_RESET
  >These notices are only updated in new installations, for existing installation manually change the notices.
- [35187](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35187) Fix line breaks in some HTML notices, including WELCOME

### OPAC

#### Other bugs fixed

- [33810](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33810) Accessibility: OPAC Advanced Search fields are not labelled
- [34946](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34946) Remove the use of event attributes from self checkout and check-in
- [34980](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34980) Remove the use of event attributes from title-actions-menu.inc in OPAC
- [35006](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35006) OPAC holdings table - sort for current library column doesn't work
  >This fixes the holdings table on the OPAC's bibliographic detail
  >page so that home and current library columns are sorted correctly by
  >library name.
- [35144](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35144) 'Required' mention for patron attributes is not red in OPAC
- [35280](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35280) OPAC patron entry form: Patron attributes "clear" link broken

### Packaging

#### Critical bugs fixed

- [35242](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35242) Force memcache restart after koha upgrade

### Patrons

#### Other bugs fixed

- [34413](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34413) Flat picker birth date field does not display properly on initial load on iOS
- [34462](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34462) Bug 25299 seems to have been reintroduced in more recent versions.
  >This fixes the display of the card expiration message on a patron's page so that it now includes the date that their card will expire.
- [34531](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34531) Hiding Lost card flag and Gone no address flag via BorrowerUnwantedFields hides Patron restrictions
- [34931](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34931) Collapsed additional attributes and identifiers with a PA_CLASS don't display well
- [35127](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35127) Patron search ignores searchtype from the context menu

### Plugin architecture

#### Other bugs fixed

- [35148](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35148) before_send_messages plugin hook does not pass the --where option

### REST API

#### Critical bugs fixed

- [35167](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35167) GET /items* broken if notforloan == 0 and itemtype.notforloan == NULL

#### Other bugs fixed

- [35053](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35053) Item-level rules not checked if both item_id and biblio_id are passed

### Searching

#### Critical bugs fixed

- [34857](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34857) OPAC advanced search operator "not" is searching as "and" on chrome
  >This fixes a regression (from bug 33233) when using a Chrome-based browser with AND, OR, and NOT in OPAC > Advanced search > More options. Using these operators with keywords should now work as expected.

### Serials

#### Critical bugs fixed

- [35073](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35073) Serials batch edit deletes unchanged additional fields data

### Staff interface

#### Critical bugs fixed

- [35284](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35284) No more delay between 2 DT requests

#### Other bugs fixed

- [31041](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31041) Cashup summary modal printing issue
  >This bugfix updates the modal printing system to trigger a new page for dialogue printing.
  >
  >Whilst this causes a minor flash unsightly content at print preview, it significantly improves the reliability of modal printing where such dialogues appear on pages containing a lot of content or the modals themselves contain a enough content to require a scroll.
- [35019](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35019) Can't delete news from the staff interface main page
- [35112](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35112) [22.11] Return claims table showing on all patron tabs and not behaving as normal

  **Sponsored by** *Pymble Ladies' College*
- [35276](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35276) Suggestions form crashes on Unknown column 'auth_forwarded_hash' when logging in
  >This fixes an issue when trying to directly access the suggestions management page in the staff interface ([YOURDOMAIN]/cgi-bin/koha/suggestion/suggestion.pl) when you are logged out. Previously, if you were logged out, tried to access the suggestions management page, and then entered your credentials, you would get an error trace.

### Templates

#### Critical bugs fixed

- [35110](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35110) Authorities editor with JS error when only one tab

#### Other bugs fixed

- [34119](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34119) Improve staff interface print stylesheet following redesign
- [34954](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34954) Typo: datexpiry
- [35055](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35055) Don't export actions column from patron search results
- [35072](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35072) Invalid usage of "&amp;" in JavaScript intranet-tmpl script redirects
- [35124](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35124) Incorrect item groups table markup
- [35212](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35212) Correct mismatched label on identity provider entry form
- [35283](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35283) XSLT 583 Action note is missing subfield h and x in staff interface

### Test Suite

#### Other bugs fixed

- [35042](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35042) Members.t: should not set datelastseen to NULL everywhere

## Enhancements 

### Acquisitions

#### Enhancements

- [34908](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34908) Sort item types alphabetically by description rather than code when adding a new empty record as an order to a basket

  **Sponsored by** *South Taranaki District Council*

### Architecture, internals, and plumbing

#### Enhancements

- [34983](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34983) Retranslating causes changes in locale_data.json
- [35043](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35043) Handling of \t in PO files is confusing
- [35079](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35079) Add option to gulp tasks po:update and po:create to control if POT should be built
- [35103](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35103) Add option to gulp tasks to pass a list of tasks
- [35174](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35174) Remove .po files from the codebase

### Cataloging

#### Enhancements

- [35198](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35198) Sort database column names alphabetically on automatic item modification page

### ILL

#### Enhancements

- [35105](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35105) ILL - Saving 'Edit request' form with invalid Patron ID causes ILL table to not render

### OPAC

#### Enhancements

- [35147](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35147) Add classes to Shibboleth text on OPAC login page

  **Sponsored by** *New Zealand Council for Educational Research*
- [35262](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35262) Improve OPAC self registration confirmation page

### Staff interface

#### Enhancements

- [33169](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33169) Improve vue breadcrumbs and left-hand menu
- [33662](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33662) Add link to order search to acq module navigation

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*

### Templates

#### Enhancements

- [35206](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35206) Adjust style of add button on curbside pickups administration

### Tools

#### Enhancements

- [29811](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29811) misc/export_records.pl add possibility to export with timestamp option on authority record type

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 22.11.12 is


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
new features in Koha 22.11.12
<div style="column-count: 2;">

- New Zealand Council for Educational Research
- Pymble Ladies' College
- South Taranaki District Council
- The Research University in the Helmholtz Association (KIT)
</div>

We thank the following individuals who contributed patches to Koha 22.11.12
<div style="column-count: 2;">

- Aleisha Amohia (7)
- Pedro Amorim (11)
- Tomás Cohen Arazi (11)
- Matt Blenkinsop (3)
- Philippe Blouin (2)
- Nick Clemens (8)
- David Cook (5)
- Jonathan Druart (21)
- emilyrose (1)
- Laura Escamilla (1)
- Katrin Fischer (13)
- Emily-Rose Francoeur (1)
- Lucas Gass (8)
- Victor Grousset (1)
- Thibaud Guillot (1)
- Kyle M Hall (3)
- Mason James (2)
- Andreas Jonsson (1)
- Jan Kissig (1)
- Michał Kula (1)
- Emily Lamancusa (3)
- Owen Leonard (16)
- Julian Maurice (10)
- Agustín Moyano (1)
- David Nind (3)
- Martin Renvoize (4)
- Marcel de Rooy (14)
- Fridolin Somers (3)
- Koha translators (1)
- Shi Yao Wang (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 22.11.12
<div style="column-count: 2;">

- Athens County Public Libraries (16)
- BibLibre (14)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (13)
- ByWater-Solutions (20)
- Catalyst (1)
- Catalyst Open Source Academy (6)
- David Nind (3)
- Koha Community Developers (22)
- KohaAloha (2)
- Kreablo AB (1)
- montgomerycountymd.gov (3)
- Prosentient Systems (5)
- PTFS-Europe (18)
- Rijksmuseum (14)
- Solutions inLibro inc (5)
- th-wildau.de (1)
- Theke Solutions (12)
- users.noreply.github.com (1)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (3)
- Pedro Amorim (40)
- Tomás Cohen Arazi (104)
- Andrew Auld (1)
- Matt Blenkinsop (94)
- Nick Clemens (17)
- David Cook (6)
- Chris Cormack (3)
- Jonathan Druart (3)
- Katrin Fischer (51)
- Andrew Fuerste-Henry (1)
- Lucas Gass (10)
- Victor Grousset (9)
- Kyle M Hall (5)
- Katariina Hanhisalo (2)
- Juliet Heltibridle (1)
- Barbara Johnson (4)
- joubu (1)
- Jan Kissig (1)
- Päivi Knuutinen (2)
- Tuomas Kunttu (1)
- Emily Lamancusa (9)
- Sam Lau (1)
- Brendan Lawlor (1)
- Owen Leonard (11)
- Kelly McElligott (4)
- Johanna Miettunen (2)
- Georgia Newman (1)
- David Nind (39)
- Reetta Pihlaja (1)
- Martin Renvoize (16)
- Phil Ringnalda (3)
- Marcel de Rooy (24)
- Michaela Sieber (2)
- Fridolin Somers (116)
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

Autogenerated release notes updated last on 28 nov 2023 14:43:19.
