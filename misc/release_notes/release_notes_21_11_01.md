# RELEASE NOTES FOR KOHA 21.11.01
22 Dec 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.11.01 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.11.01.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.11.01 is a bugfix/maintenance release.

It includes 1 enhancements, 29 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### REST API

- [[29620]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29620) Move the OpenAPI spec to YAML format

  >This enhancement moves all the Koha REST API specification from json to YAML format. It also corrects two named parameters incorrectly in camelCase to sanake_case (fundidPathParam => fund_id_pp, vendoridPathParam => vendor_id_pp).


## Critical bugs fixed

### Architecture, internals, and plumbing

- [[29631]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29631) 21.06.000.12 may fail

  >This fixes an issue when upgrading from 21.05.x to 21.11 - the uniq_lang unique key is failing to be created because several rows with the same subtag and type exist in database table language_subtag_registry.

### Circulation

- [[29637]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29637) AutoSwitchPatron is broken since Bug 26352

  >This fixes an issue introduced by bug 26352 in 21.11 that caused the AutoSwitchPatron system preference to no longer work. (When AutoSwitchPatron is enabled and a patron barcode is scanned instead of a book, it automatically redirects to the patron.)

### Fines and fees

- [[27801]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27801) Entering multiple lines of an item in Point of Sale can make the Collect Payment field off

  >This fixes the POS transactions page so that the total for the sale and the amount to collect are the same.
  >
  >Before this a POS transaction with multiple items in the Sale box, say for example 9 x .10 items, the total in the Sale box appears correct, but the amount to Collect from Patron is off by a cent.

### Hold requests

- [[29349]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29349) Item-level holds should assume the same pickup location as bib-level holds

  >Up until Koha 20.11 the pickup location when placing item-level holds was the currently logged-in library.
  >
  >From Koha 21.05 the holding branch was used as the default.
  >
  >This restores the previous behaviour so that the logged-in library (if a valid pickup location) is selected as the default pickup location for item-level holds. When it is not, an empty dropdown is used as a fallback.

### Lists

- [[29669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29669) Uninitialized value warnings when XSLTParse4Display is called

### Notices

- [[29586]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29586) "Hold reminder" notice doesn't show in messaging preferences in new installation

  >This fixes an issue with the installer files that meant "Hold reminder" notices were not shown in messaging preferences for new installations.


## Other bugs fixed

### Acquisitions

- [[28855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28855) Purging suggestions test should not be on timestamp

  >This changes the date field that cronjob misc/cronjobs/purge_suggestions.pl uses to calculate the number of days for deleting accepted or rejected suggestions. It now uses the managed on date, as the last updated date that was used can be changed by other database updates.

### Architecture, internals, and plumbing

- [[29494]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29494) html-template-to-template-toolkit.pl no longer required

### Authentication

- [[29487]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29487) Set autocomplete off for userid/password fields at login

  >This turns autocompletion off for userid and password fields on the login forms for the OPAC and staff interface.

### Cataloging

- [[9565]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9565) Deleting a record should alert or fail if there are current subscriptions

  >This change prevents the deletion of records with current serial subscriptions. 
  >
  >Selecting "Delete record" when there are existing subscriptions no longer deletes the record and subscription, and adds an alert box "[Count] subscription(s) are attached to this record. You must delete all subscriptions before deleting this record.".
  >
  >It also:
  >- adds a "Subscriptions" column in the batch deletion records tool with the number of subscriptions and a link to the search page with all the subscriptions for the record, and
  >- adds a button in the toolbar to enable selecting only records without subscriptions.
- [[28853]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28853) Textarea in biblio record editor breaks authority plugin

  >This fixes an issue when adding or editing record subfields using the authority plugin and it has a value with more than 100 characters. (When a subfield has more than 100 characters it changes to a text area rather than a standard input field, this caused JavaScript issues when using authority terms over 100 characters.)

### Fines and fees

- [[28481]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28481) Register details "Older transactions" search does not include the selected day in the "To" field in date range

  >This fixes the search and display of older transactions in the cash register so that items from today are included in the results. Previously, transactions for the current day were incorrectly not included.

### Hold requests

- [[29115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29115) Placing a club hold is not showing warnings when unable to place a hold

  >This fixes placing club holds so that checks are correctly made and warning messages displayed when patrons are debarred or have outstanding fees and charges.

### I18N/L10N

- [[29040]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29040) Uninitialized value warning in Languages.pm

  >This removes the cause of the warning message "Use of uninitialized value $interface in concatenation (.) or string at /kohadevbox/koha/C4/Languages.pm line 121." when editing item types.

### Lists

- [[29601]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29601) The list download option ISBD is useless when you cleared OPACISBD

### OPAC

- [[29036]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29036) Accessibility: OPAC buttons don't have sufficient contrast

  >This improves the accessibility of the OPAC by increasing the contrast ratio for buttons, making the button text easier to read. 
  >
  >As part of this change the OPAC SCSS was modified so that a "base theme color" variable is defined which can be used to color button backgrounds and similar elements. It also moves some other colors into variables and removes some unused CSS.
- [[29556]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29556) MARC21slim2MODS.xsl broken by duplicate template name "part"

  >This fixes an error when making an unAPI request in the OPAC using the MODS format. A 500 page error was displayed instead of an XML file. Example URL: http://your-library-opac-domain/cgi-bin/koha/unapi?id=koha:biblionumber:1&format=MODS
- [[29611]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29611) Clubs enrollment layout problem in the OPAC

  >This fixes a minor HTML issue with the clubs enrollment form in the OPAC. The "Finish enrollment" button is now positioned correctly inside the bordered area and uses standard colors.

### REST API

- [[29593]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29593) Wrong tag in GET /public/libraries spec

  >This updates the tag in GET /public/libraries (api/v1/swagger/paths/libraries.json file) from library to libraries.

### Reports

- [[29488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29488) NumSavedReports system preference doesn't work

  >This fixes the saved reports page so that the NumSavedReports system preference works as intended - the number of reports listed should default to the value in the system preference (the initial default is 20).
- [[29679]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29679) Reports result menu shows too many dividers

  >This removes borders between sections that are not required. The SQL report batch operations dropdown menu has divider list items which add a border between sections (bibliographic records, item records, etc.). This element is redundant because the sections have "headers" which also add a border.

### Serials

- [[28216]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28216) Fix vendor list group by in serials statistics wizard

  >This fixes an issue where vendors are repeated in the serials report.

### Templates

- [[29513]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29513) Accessibility: Staff Client - Convert remaining breadcrumbs sections from div to nav blocks

  >This improves the accessibility of breadcrumbs so that they adhere to the WAI-ARIA Authoring Practices. It covers additional breadcrumbs that weren't fixed in bug 27486 in these areas: 
  >* Home > Acquisitions > [Vendor name > [Basket name]
  >* Home > Administration > Set library checkin and transfer policy
  >* Home > Patrons > Merge patron records
- [[29514]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29514) ILL requests: Remove extraneous &rsaquo; HTML entity from breadcrumbs

  >This fixes a small typo in the breadcrumbs section for ILL requests - it had an extra &rsaquo; HTML entity after "Home".
- [[29528]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29528) Breadcrumbs on HTML customizations take you to news

  >This change removes the "Additional contents" breadcrumb when working with news items or HTML customizations. Since news and HTML customizations are separate links on the tools home page there's no reason to have the breadcrumbs imply the two sections are connected in any way. We already have the "See News" link, for example, for switching quickly between the two areas.
- [[29529]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29529) Fix \n in hint on Koha to MARC mappings

  >This fixes:
  >- a string in Koha to MARC mappings (koha2marclinks.tt:86) so that it can be correctly translated (excludes "\n" from what is translated), and
  >- capitalization for the breadcrumb link: Administration > Koha to MARC mappings.
- [[29580]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29580) Misplaced closing 'td' tag in overdue.tt

### Tools

- [[29521]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29521) Patron Club name hyperlinks not operational + weird CSS behavior

  >This removes the link from thea patron club name on the patrons club listing page as it didn't work. It also improves the consistency of the table of patron clubs so that the interface is consistent whether you're looking at clubs during the holds process or during the clubs management view.

### Web services

- [[29484]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29484) ListSets doesn't return noSetHierarchy when appropriate

  >This fixes Koha's OAI-PMH server so that it returns the appropriate error code when no sets are defined.



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)



The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (88.3%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (93%)
- Chinese (Taiwan) (79.7%)
- Czech (69.4%)
- English (New Zealand) (59.7%)
- English (USA)
- Finnish (84.1%)
- French (88.7%)
- French (Canada) (84.8%)
- German (100%)
- German (Switzerland) (59.3%)
- Greek (53.2%)
- Hindi (100%)
- Italian (91.1%)
- Nederlands-Nederland (Dutch-The Netherlands) (60.6%)
- Norwegian Bokmål (64%)
- Polish (99.4%)
- Portuguese (89.3%)
- Portuguese (Brazil) (84.6%)
- Russian (85.5%)
- Slovak (70.6%)
- Spanish (100%)
- Swedish (83%)
- Telugu (96.4%)
- Turkish (96.5%)
- Ukrainian (64%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.11.01 is


- Release Manager: Fridolin Somers

- Release Manager assistants:
  - Jonathan Druart
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Andrew Nugged
  - Jonathan Druart
  - Joonas Kylmälä
  - Kyle M Hall
  - Marcel de Rooy
  - Martin Renvoize
  - Nick Clemens
  - Petro Vashchuk
  - Tomás Cohen Arazi
  - Victor Grousset

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Indranil Das Gupta
  - Erica Rohlfs

- Packaging Manager: 


- Documentation Manager: David Nind


- Documentation Team:
  - Aude Charillon
  - Caroline Cyr La Rose
  - Kelly McElligott
  - Lucy Vaux-Harvey
  - Martin Renvoize
  - Rocio Lopez

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth

- Release Maintainers:
  - 21.11 -- Kyle M Hall
  - 21.05 -- Andrew Fuerste-Henry
  - 20.11 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

## Credits

We thank the following individuals who contributed patches to Koha 21.11.01

- Tomás Cohen Arazi (8)
- Henry Bolshaw (1)
- Nick Clemens (3)
- Jonathan Druart (6)
- Marion Durand (4)
- Katrin Fischer (1)
- Lucas Gass (2)
- Michael Hafen (1)
- Kyle M Hall (10)
- Joonas Kylmälä (1)
- Owen Leonard (7)
- Martin Renvoize (3)
- Marcel de Rooy (1)
- Andreas Roussos (2)
- Fridolin Somers (4)
- Koha translators (1)
- Petro Vashchuk (1)
- Timothy Alexis Vass (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.11.01

- Athens County Public Libraries (7)
- BibLibre (8)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (1)
- ByWater-Solutions (15)
- Dataly Tech (2)
- Independant Individuals (2)
- Koha Community Developers (6)
- PTFS-Europe (3)
- Rijksmuseum (1)
- Theke Solutions (8)
- ub.lu.se (1)
- UK Parliament (1)
- washk12.org (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (7)
- Florian Bontemps (1)
- jeremy breuillard (2)
- Jonathan Druart (21)
- Katrin Fischer (10)
- Andrew Fuerste-Henry (1)
- Lucas Gass (1)
- Kyle M Hall (46)
- Frank Hansen (3)
- Sally Healey (1)
- Samu Heiskanen (2)
- Barbara Johnson (2)
- Owen Leonard (5)
- David Nind (18)
- Séverine Queune (1)
- Martin Renvoize (5)
- Marcel de Rooy (5)
- Andreas Roussos (1)
- Fridolin Somers (40)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 22 Dec 2021 13:21:45.
