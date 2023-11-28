# RELEASE NOTES FOR KOHA 23.05.06
28 Nov 2023

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 23.05.06 can be downloaded from:

- [Download](http://download.koha-community.org/koha-23.05.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 23.05.06 is a bugfix/maintenance release.

It includes 19 enhancements, 62 bugfixes including 2 security fixes.

**System requirements**

You can learn about the system components (like OS and database) needed for running Koha on the [community wiki](https://wiki.koha-community.org/wiki/System_requirements_and_recommendations).


#### Security bugs

- [35290](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35290) SQL Injection vulnerability in ysearch.pl
- [35291](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35291) File Upload vulnerability in upload-cover-image.pl

## Bugfixes

### About

#### Other bugs fixed

- [34424](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34424) Update release team on about page for new QA team member
- [35033](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35033) Add a validation for biblioitems in about/system information

### Acquisitions

#### Critical bugs fixed

- [35004](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35004) Cannot receive order lines with items created in cataloguing
- [35254](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35254) Adding files to basket from a staged file uses wrong inputs for order information when not all records are selected
- [35273](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35273) When editing items on receive, aqorders_items is not updated correctly

#### Other bugs fixed

- [22712](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=22712) Funds from inactive budgets appear on Item details if using MarcItemFieldstoOrder
- [34375](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34375) Shipping fund in an invoice defaults to the first fund from the list rather than 'no fund' after receiving
- [35012](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35012) Framework item plugins fire twice on Acquisition item blocks

### Architecture, internals, and plumbing

#### Critical bugs fixed

- [34959](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34959) Translator tool generates too many changes

#### Other bugs fixed

- [32379](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32379) CRASH: Can't call method "itemlost" on an undefined value
- [35024](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35024) Do not wrap PO files
- [35173](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35173) Call concat correctly for EDI SFTP Transport errors
- [35190](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35190) Additional_fields table should allow null values for authorised_value_category
- [35278](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35278) CGI::param called in list context from /usr/share/koha/admin/columns_settings.pl line 76
- [35298](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35298) Flatpickr makes focus handler in dateaccessioned plugin useless

### Authentication

#### Other bugs fixed

- [31393](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=31393) Koha::Config->read_from_file incorrectly parses elements with 1 attribute named" content" (Shibboleth config)

### Cataloging

#### Critical bugs fixed

- [34993](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34993) Framework doesn't load defaults in existing records or duplicate as new
- [35181](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35181) Can no longer edit sample records with advanced cataloguing editor

#### Other bugs fixed

- [32853](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32853) Fix cataloguing/value_builder/unimarc_field_125.pl
- [32856](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32856) Fix cataloguing/value_builder/unimarc_field_126.pl
- [34966](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34966) Terminology: Add item form - "Add & duplicate" should be "Add and duplicate"
  >This updates the add item form in the staff interface to
  >change the 'Add & duplicate' button to 'Add and duplicate'. (As per the terminology guidelines https://wiki.koha-community.org/wiki/Terminology)
- [35245](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35245) Incorrect select2 width when cataloging authorities

### Circulation

#### Critical bugs fixed

- [17798](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17798) Checking out an item on hold for another patron prints a slip but does not update hold
- [35295](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35295) No hold modal when checking in an item of a held record

#### Other bugs fixed

- [27992](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27992) When recording local use with statistical patron items are not checked in
- [29007](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29007) Prompt for reason when cancelling waiting hold via popup
  >This adds the option to record the hold cancellation reason on the check in form for waiting holds (similar to when cancelling holds from the record details' holds page).
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
- [35171](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35171) runreport.pl cronjob should optionally send an email when the report has no results
  >This enhancement adds a new 'send_empty' option to runreport.pl. Currently, if there are no results for a report, then no email is sent. This option lets libraries know that a report was run overnight and that it had no results. Example: perl misc/cronjobs/runreport.pl 1 --send_empty --email

### Hold requests

#### Critical bugs fixed

- [35307](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35307) Expired holds are missing an input, so updating holds causes loss of data

#### Other bugs fixed

- [34678](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34678) Concurrent changes to the holds can fail due to primary key constraints
- [35003](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35003) Holds with cancellation requests table on waitingreserves.tt does not filter by branch

### I18N/L10N

#### Other bugs fixed

- [32312](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=32312) Complete database column descriptions for circulation module in guided reports
  >This adds and clarifies database column descriptions shown for the statistics table when creating a guided report for the circulation module. Previously, some columns didn't have a description or were ambiguous.

### Installation and upgrade (command-line installer)

#### Other bugs fixed

- [35180](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35180) Fix typo in deletedbiblioitems.publishercode comment in kohastructure.sql

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
- [35144](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35144) 'Required' mention for patron attributes is not red in OPAC
- [35266](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35266) opac-MARCdetail: Can't call method "metadata" on an undefined value
  >This fixes the display of the MARC view page when a record does not exist - it now redirects to the 404 (page not found) page. Previously, it generated an error trace, where the normal and ISBD view pages redirected to the 404 (page not found) page.
- [35280](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35280) OPAC patron entry form: Patron attributes "clear" link broken

### Packaging

#### Critical bugs fixed

- [35242](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35242) Force memcache restart after koha upgrade

### Patrons

#### Other bugs fixed

- [34413](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34413) Flat picker birth date field does not display properly on initial load on iOS
- [34931](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34931) Collapsed additional attributes and identifiers with a PA_CLASS don't display well

### Searching

#### Critical bugs fixed

- [34857](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34857) OPAC advanced search operator "not" is searching as "and" on chrome
  >This fixes a regression (from bug 33233) when using a Chrome-based browser with AND, OR, and NOT in OPAC > Advanced search > More options. Using these operators with keywords should now work as expected.

### Self checkout

#### Other bugs fixed

- [34557](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34557) Add option to prevent loading a patron's checkouts on the SCO

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
- [35276](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35276) Suggestions form crashes on Unknown column 'auth_forwarded_hash' when logging in
  >This fixes an issue when trying to directly access the suggestions management page in the staff interface ([YOURDOMAIN]/cgi-bin/koha/suggestion/suggestion.pl) when you are logged out. Previously, if you were logged out, tried to access the suggestions management page, and then entered your credentials, you would get an error trace.

### System Administration

#### Other bugs fixed

- [35078](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35078) Invalid HTML in OpacShowSavings system preference

### Templates

#### Other bugs fixed

- [34624](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34624) Many header search forms lack for attribute for label
- [34954](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34954) Typo: datexpiry
- [35205](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35205) Fix duplicate id attribute in desks search form
- [35212](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35212) Correct mismatched label on identity provider entry form
- [35272](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35272) Add padding above vendor contracts section
- [35283](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35283) XSLT 583 Action note is missing subfield h and x in staff interface

### Test Suite

#### Other bugs fixed

- [35215](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35215) Make a few assumptions more explicit in Suggestions.t

## Enhancements 

### Architecture, internals, and plumbing

#### Enhancements

- [35043](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35043) Handling of \t in PO files is confusing
- [35079](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35079) Add option to gulp tasks po:update and po:create to control if POT should be built
- [35103](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35103) Add option to gulp tasks to pass a list of tasks
- [35174](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35174) Remove .po files from the codebase

### Cataloging

#### Enhancements

- [35198](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35198) Sort database column names alphabetically on automatic item modification page

### Circulation

#### Enhancements

- [34938](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34938) Add collection column to holds ratio report (circ/reserveratios.pl)
- [35253](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35253) Make materials specified note easier to customize
  >This enhancement adds classes to the materials specified messages that are displayed when checking out and checking in an item, when there is a value for an item in 952$3.  The new classes available for customizing IntranetUserCSS are mats_spec_label and mats_spec_message.
  >
  >Example CSS customization:
  > .mats_spec_label { color: white; background: purple;  }
  > .mats_spec_message { color: white; background: green; }

### Command-line Utilities

#### Enhancements

- [33050](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33050) Allow to specify quote char in runreport.pl

### Database

#### Enhancements

- [34328](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34328) Scottish Gaelic is missing from the language_rfc4646_to_iso639 table

### OPAC

#### Enhancements

- [35147](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35147) Add classes to Shibboleth text on OPAC login page

  **Sponsored by** *New Zealand Council for Educational Research*
- [35262](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35262) Improve OPAC self registration confirmation page

### REST API

#### Enhancements

- [34008](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=34008) REST API: Add a list (GET) endpoint for itemtypes

### Staff interface

#### Enhancements

- [33662](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=33662) Add link to order search to acq module navigation

  **Sponsored by** *The Research University in the Helmholtz Association (KIT)*

### Templates

#### Enhancements

- [35206](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35206) Adjust style of add button on curbside pickups administration

### Tools

#### Enhancements

- [24480](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24480) Fields added with MARC modifications templates are not added in an ordered way
- [29811](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29811) misc/export_records.pl add possibility to export with timestamp option on authority record type

### Web services

#### Enhancements

- [21284](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21284) ILS-DI: Allow GetPatronInfo to tell if a checked out item is on hold for someone else
  >This enhancement adds two new entries in the loans section of a GetPatronInfo response:
  >
  >- item_on_hold: number of holds on this specific item
  >- record_on_hold: number of holds on the record
  >
  >This allows an ILS-DI client to know if a loaned item is already on hold by someone else, and how many holds there are.
- [35008](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=35008) ILS-DI should not ask for login with OpacPublic disabled

  **Sponsored by** *Auckland University of Technology*

## New system preferences

- SCOLoadCheckoutsByDefault

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Translation process has moved to a dedicated repository:

- [Koha L10N Git Repository](https://gitlab.com/koha-community/koha-l10n)

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 23.05.06 is


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
new features in Koha 23.05.06
<div style="column-count: 2;">

- Auckland University of Technology
- New Zealand Council for Educational Research
- Pymble Ladies' College
- The Research University in the Helmholtz Association (KIT)
</div>

We thank the following individuals who contributed patches to Koha 23.05.06
<div style="column-count: 2;">

- Aleisha Amohia (5)
- Pedro Amorim (4)
- Tomás Cohen Arazi (10)
- Matt Blenkinsop (2)
- Philippe Blouin (1)
- Nick Clemens (14)
- David Cook (5)
- Jonathan Druart (17)
- Laura Escamilla (1)
- Katrin Fischer (12)
- Lucas Gass (9)
- Victor Grousset (2)
- Thibaud Guillot (2)
- Kyle M Hall (3)
- Mason James (2)
- Andreas Jonsson (2)
- Jan Kissig (1)
- Emily Lamancusa (4)
- Owen Leonard (14)
- Julian Maurice (5)
- Matthias Meusburger (1)
- David Nind (2)
- Martin Renvoize (5)
- Marcel de Rooy (8)
- Slava Shishkin (1)
- Fridolin Somers (7)
- Arthur Suzuki (2)
- Koha translators (1)
</div>

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 23.05.06
<div style="column-count: 2;">

- Athens County Public Libraries (14)
- BibLibre (17)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (12)
- ByWater-Solutions (27)
- Catalyst Open Source Academy (5)
- David Nind (2)
- Independant Individuals (1)
- Koha Community Developers (19)
- KohaAloha (2)
- Kreablo AB (2)
- montgomerycountymd.gov (4)
- Prosentient Systems (5)
- PTFS-Europe (11)
- Rijksmuseum (8)
- Solutions inLibro inc (1)
- th-wildau.de (1)
- Theke Solutions (10)
</div>

We also especially thank the following individuals who tested patches
for Koha
<div style="column-count: 2;">

- Aleisha Amohia (3)
- AndrewA (2)
- Tomás Cohen Arazi (103)
- Andrew Auld (2)
- Matt Blenkinsop (1)
- Nick Clemens (9)
- David Cook (5)
- Chris Cormack (1)
- Jonathan Druart (5)
- Katrin Fischer (56)
- Andrew Fuerste-Henry (2)
- Lucas Gass (7)
- Victor Grousset (9)
- Kyle M Hall (6)
- Katariina Hanhisalo (1)
- Juliet Heltibridle (1)
- joubu (1)
- Jan Kissig (1)
- Päivi Knuutinen (2)
- Emily Lamancusa (10)
- Brendan Lawlor (1)
- Owen Leonard (8)
- Kelly McElligott (4)
- Johanna Miettunen (2)
- Georgia Newman (1)
- David Nind (30)
- Reetta Pihlaja (1)
- Martin Renvoize (5)
- Phil Ringnalda (8)
- Marcel de Rooy (22)
- Caroline Cyr La Rose (2)
- Michaela Sieber (1)
- Fridolin Somers (117)
</div>





We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 23.05.x-security.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 28 Nov 2023 18:39:26.
