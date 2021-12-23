# RELEASE NOTES FOR KOHA 21.05.08
23 Dec 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.05.08 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.05.08.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.08 is a bugfix/maintenance release.

It includes 24 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations






## Critical bugs fixed

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

### OPAC

- [[28698]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28698) News for all displays in all locations

  >This corrects the display of news items in the OPAC - if a location was not selected when creating a news item it was displaying in all locations (news, header, right, and so on). It also now displays in the right location for any language.


## Other bugs fixed

### Acquisitions

- [[28855]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28855) Purging suggestions test should not be on timestamp

  >This changes the date field that cronjob misc/cronjobs/purge_suggestions.pl uses to calculate the number of days for deleting accepted or rejected suggestions. It now uses the managed on date, as the last updated date that was used can be changed by other database updates.

### Architecture, internals, and plumbing

- [[29427]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29427) Debug mode not honoured in SMTP transport

  >The debug flag on the SMTP servers configuration was not being used correctly. This patch implements the expected behavior.
  >
  >Note: Enabling this will lead to lots of logging for each SMTP connection Koha does.
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

### Reports

- [[29488]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29488) NumSavedReports system preference doesn't work

  >This fixes the saved reports page so that the NumSavedReports system preference works as intended - the number of reports listed should default to the value in the system preference (the initial default is 20).

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

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/21.05/ar/html/) (34.3%)
- [Chinese (Taiwan)](https://koha-community.org/manual/21.05/zh_TW/html/) (58.7%)
- [Czech](https://koha-community.org/manual/21.05/cs/html/) (27.6%)
- [English (USA)](https://koha-community.org/manual/21.05/en/html/)
- [French](https://koha-community.org/manual/21.05/fr/html/) (51.8%)
- [French (Canada)](https://koha-community.org/manual/21.05/fr_CA/html/) (25.2%)
- [German](https://koha-community.org/manual/21.05/de/html/) (73.5%)
- [Hindi](https://koha-community.org/manual/21.05/hi/html/) (100%)
- [Italian](https://koha-community.org/manual/21.05/it/html/) (48.1%)
- [Spanish](https://koha-community.org/manual/21.05/es/html/) (36.9%)
- [Turkish](https://koha-community.org/manual/21.05/tr/html/) (40.3%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (90%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (82.5%)
- Czech (71.4%)
- English (New Zealand) (61.5%)
- English (USA)
- Finnish (82.5%)
- French (92.1%)
- French (Canada) (87.6%)
- German (100%)
- German (Switzerland) (60.8%)
- Greek (54.9%)
- Hindi (100%)
- Italian (94%)
- Nederlands-Nederland (Dutch-The Netherlands) (61.7%)
- Norwegian Bokmål (65.9%)
- Polish (100%)
- Portuguese (91.3%)
- Portuguese (Brazil) (87.2%)
- Russian (86.7%)
- Slovak (72.8%)
- Spanish (100%)
- Swedish (77%)
- Telugu (99.7%)
- Turkish (99.7%)
- Ukrainian (69.1%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.08 is


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

We thank the following individuals who contributed patches to Koha 21.05.08

- Tomás Cohen Arazi (6)
- Henry Bolshaw (1)
- Nick Clemens (1)
- Jonathan Druart (2)
- Marion Durand (4)
- Katrin Fischer (1)
- Andrew Fuerste-Henry (3)
- Lucas Gass (2)
- Joonas Kylmälä (1)
- Owen Leonard (5)
- Martin Renvoize (3)
- Marcel de Rooy (1)
- Andreas Roussos (2)
- Fridolin Somers (5)
- Koha translators (1)
- Timothy Alexis Vass (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.08

- Athens County Public Libraries (5)
- BibLibre (9)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (1)
- ByWater-Solutions (6)
- Dataly Tech (2)
- Independant Individuals (1)
- Koha Community Developers (2)
- PTFS-Europe (3)
- Rijksmuseum (1)
- Theke Solutions (6)
- ub.lu.se (1)
- UK Parliament (1)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (3)
- Florian Bontemps (1)
- jeremy breuillard (2)
- Nick Clemens (2)
- Jonathan Druart (17)
- Katrin Fischer (10)
- Andrew Fuerste-Henry (36)
- Lucas Gass (1)
- Kyle M Hall (28)
- Frank Hansen (3)
- Samu Heiskanen (2)
- Barbara Johnson (1)
- Owen Leonard (5)
- David Nind (11)
- Séverine Queune (1)
- Martin Renvoize (4)
- Marcel de Rooy (4)
- Andreas Roussos (1)
- Sally (1)
- Fridolin Somers (24)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is rmain2105.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Dec 2021 15:49:47.
