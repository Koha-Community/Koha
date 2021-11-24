# RELEASE NOTES FOR KOHA 21.05.06
24 Nov 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 21.05.06 can be downloaded from:

- [Download](http://download.koha-community.org/koha-21.05.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 21.05.06 is a bugfix/maintenance release.

It includes 3 enhancements, 63 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Plugin architecture

- [[27173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27173) Add plugin hooks for authority record changes

  >This enhancement allows plugin authors to implement an `after_authority_action` method in order to act upon authority create, modify and delete.
- [[28474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28474) Pass process_message_queue.pl params to before_send_messages plugin hooks

  >This enhancement passes the parameters received by process_message_queue.pl through to the before_send_messages plugin calls. This allows plugins to respect calls that should only affect certain letter codes etc.

### REST API

- [[17314]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17314) Routes to create, list and delete a purchase suggestion


## Critical bugs fixed

### Acquisitions

- [[14999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14999) Adding to basket orders from staged files mixes up the prices between different orders
- [[29283]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29283) Cannot delete basket with cancelled order for deleted biblio

### Architecture, internals, and plumbing

- [[26374]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26374) Update for 19974 is not idempotent
- [[29330]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29330) Koha cannot send emails with attachments using Koha::Email and message_queue table
- [[29386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29386) background jobs table data field is a TEXT which is too small

### Circulation

- [[29255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29255) Built-in offline circulation broken with SQL error

### Command-line Utilities

- [[28994]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28994) Make writeoff_debts.pl use amountoutstanding, not amount

### Notices

- [[28803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28803) process_message_queue.pl dies if any messsages in the message queue contain an invalid to_address
- [[29223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29223) Auto-renewals can fail when not digested per branch and patron requests digest

### OPAC

- [[28870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28870) Cart shipping fails because of Non-ASCII characters in display-name of reply-to address
- [[29318]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29318) OverDrive search page should not require edit_borrowers permission
- [[29416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29416) Regression: information from existing bib no longer populating on suggest for purchase

  >This restores the behaviour for purchase suggestions for an existing title, so that the suggestion form is pre-filled with the details from the existing record.

### Patrons

- [[29341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29341) If OpacRenewalBranch = opacrenew, pseudonymization process leads to "internal server error" when patrons renew the loans at OPAC
- [[29524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29524) Cannot set a new value for privacy_guarantor_checkouts in memberentry.pl

### REST API

- [[28585]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28585) Cannot search on date fields

  >This patch fixes the date handling for query parsing from the API.  We use dt_from_string to convert out RFC3339 formatted date strings to DateTime objects with an associated timezone and then user the native datetime formatted provided by the SQL connection library to convert to an appropriately formated date time string.
- [[29272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29272) API not respecting $category->effective_change_password

### Reports

- [[29204]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29204) Error 500 when execute Circulation report with date period

### SIP2

- [[26871]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26871) L1 cache still too long in SIP Server

  >This fixes SIP connections so that when system preference and configuration changes are made (for example: enabling or disabling logging of issues and returns) they are picked up automatically with the next message, rather than requiring the SIP connection to be closed and reopened.
  >
  >SIP connections typically tend to be long lived - weeks if not months. Basically the connection per SIP machine is initiated once when the SIP machine boots and then never closed until maintenance is required. Therefore we need to reset Koha's caches on every SIP request to get the latest system preference and configuration changes from the memcached cache that is shared between all the Koha programs (staff interface, OPAC, SIP, cronjobs, etc).
- [[29264]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29264) SIP config allows use of non-branchcode institution ids causes workers to die without responding

  >This adds a warning to the logs where a SIP login uses an institution id that is *not* a valid library code.
  >
  >If a SIP login uses an institution with an id that doesn't match a valid branchcode, everything will appear to work, but the SIP worker will die anywhere that Koha gets the branch from the userenv and assumes it is valid.
  >
  >The repercussions of this are that actions such as the checkout message simply die and do not return a response message to the requestor.

### Searching

- [[29152]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29152) Change to default search behavior when limiting by branch

### Searching - Elasticsearch

- [[29284]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29284) Koha dies when an analytics search fails in Elasticsearch

### Staff Client

- [[28573]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28573) Replace authority record with Z39.50/SRU creates new authority record

### System Administration

- [[28729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28729) Return-path header not set in emails


## Other bugs fixed

### About

- [[28904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28904) Update information on Newsletter editor on about page
- [[29123]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29123) Add Dataly Tech to About page
- [[29300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29300) Release team 22.05

### Acquisitions

- [[27708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27708) Cannot create EDI order if AcqCreateItem value is not "placing an order"
- [[28627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28627) Revert the order receive page to display 'Actual cost' as ecost_tax_included/ecost_tax_excluded if unitprice not set

### Architecture, internals, and plumbing

- [[29218]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29218) "hidden" class is not working for DT if column visibility button is used
- [[29321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29321) Remove a last without loop context
- [[29350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29350) TT method 'delete' don't need to be escaped
- [[29408]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29408) The datatables api wrapper is ambiguously named

  >This patch 1) renames the Koha REST JS dataTables wrapper from the
  >ambiguous 'api' to the clearer 'kohaTable' 2) goes through the codebase and updates existing relevant calls to .api referencing the Koha REST dataTables wrapper to use the name 'kohaTable', and 3) adds JSDoc formatted parameter documentation for the kohaTable function.

### Cataloging

- [[29319]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29319) Errors when doing a cataloging search which starts with a number + letter

  >This fixes an error that occurs in cataloging search when entering a search term with ten characters (like "7th Heaven" or "2nd editio") - Koha thinks you are entering an ISBN10 number, gets confused and delivers an error page. Searching now works as expected for ISBN13/ISBN10 (without the '-'s), title and author searches.
- [[29437]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29437) 500 error when performing a catalog search for an ISBN13 with no valid ISBN10

### Fines and fees

- [[29309]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29309) 'Pay all fines' should be 'Pay all charges'

### Label/patron card printing

- [[25459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25459) In patron cards layout, barcode position doesn't respect units

### Notices

- [[29460]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29460) Typo 'pendin    g approval'

### OPAC

- [[28768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28768) OPAC reading history page (opac-readingrecord.pl) wont display news items
- [[28901]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28901) showCart incorrectly calculates position if content above navbar
- [[28910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28910) Correct eslint errors in OPAC basket.js
- [[29329]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29329) stray "s" in opac-detail

### Patrons

- [[27145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27145) Patron deletion via intranet doesn't handle exceptions well
- [[28973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28973) Improve Koha::Patron::can_see_patron_infos efficiency
- [[29213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29213) Typo ol in member-alt-contact-style.inc
- [[29227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29227) Patron messaging preferences digest show as editable but are not

### REST API

- [[28613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28613) Several objects.search-based routes missing parameters
- [[29405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29405) The patron spec for date_renewed is missing it's format definition

  >This fix adds the date format string to the date_renewed field. This is to ensure that the date_renewed field can be correctly validated.

### Reports

- [[27884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27884) Add HTML mail support for patron emailer script
- [[29328]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29328) Add missing list parameter to reports parameter menu
- [[29352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29352) Runtime parameter labels should not be said to be optional

### SIP2

- [[29452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29452) Unnecessary warns in sip logs

### Searching

- [[28365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28365) (Bug 19873 follow-up) Make it possible to search on value 0
- [[28847]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28847) Branch limits while searching should be expanded in query building and not in CGI

### Staff Client

- [[28913]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28913) Automatic checkin setting in item type setup should note required cronjob
- [[29195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29195) Highlighting broken on odd rows in circ-patron-search-results

### System Administration

- [[29075]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29075) OPAC info should not be displayed in libraries table
- [[29456]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29456) "Auto renewal" and "Hold reminder" notice shown as "unknown" on the patron category list view

### Templates

- [[29286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29286) Typo: Librarien will need the manage_auth_values subpermission.

### Test Suite

- [[29306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29306) Holds.t: Fix Use of uninitialized value $_ in concatenation (.) or string
- [[29315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29315) Remove warnings from Search.t
- [[29363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29363) TestBuilder.t failing if biblionumber=123 does not exist
- [[29364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29364) Search.t not reverting changes made to the framework

### Web services

- [[21105]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21105) oai.pl returns invalid earliestDatestamp

  **Sponsored by** *Reformational Study Centre*

  >This fixes the date format in OAI-PMH for Identify.earliestDatestamp so that it uses "YYYY-MM-DDThh:mm:ssZ" and is in UTC, instead of the SQL formsat "YYYY-MM-DD hh:mm:ss" currently used. For OAI-PMH all date and time values must be in the format "YYYY-MM-DDThh:mm:ssZ" and in UTC.



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
- [Spanish](https://koha-community.org/manual/21.05/es/html/) (34.8%)
- [Turkish](https://koha-community.org/manual/21.05/tr/html/) (40.3%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (90%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Chinese (Taiwan) (82.3%)
- Czech (71.4%)
- English (New Zealand) (61.5%)
- English (USA)
- Finnish (82.6%)
- French (91.9%)
- French (Canada) (87.6%)
- German (100%)
- German (Switzerland) (60.8%)
- Greek (55%)
- Hindi (100%)
- Italian (93.5%)
- Nederlands-Nederland (Dutch-The Netherlands) (61.7%)
- Norwegian Bokmål (65.9%)
- Polish (100%)
- Portuguese (91.4%)
- Portuguese (Brazil) (87.2%)
- Russian (86.7%)
- Slovak (72.8%)
- Spanish (96.3%)
- Swedish (77.1%)
- Telugu (99.8%)
- Turkish (99.8%)
- Ukrainian (68.3%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 21.05.06 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - Agustín Moyano
  - Andrew Nugged
  - David Cook
  - Joonas Kylmälä
  - Julian Maurice
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
  - Elasticsearch -- Fridolin Somers
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Sally Healey

- Packaging Manager: 


- Documentation Manager: David Nind


- Documentation Team:
  - David Nind
  - Lucy Vaux-Harvey

- Translation Managers: 
  - Bernardo González Kriegel

- Wiki curators: 
  - Thomas Dukleth

- Release Maintainers:
  - 21.05 -- Kyle M Hall
  - 20.11 -- Fridolin Somers
  - 20.05 -- Victor Grousset
  - 19.11 -- Wainui Witika-Park

- Release Maintainer assistants:
  - 21.05 -- Nick Clemens

- Release Maintainer mentors:
  - 19.11 -- Aleisha Amohia

## Credits
We thank the following libraries, companies, and other institutions who are known to have sponsored
new features in Koha 21.05.06

- Reformational Study Centre

We thank the following individuals who contributed patches to Koha 21.05.06

- Tomás Cohen Arazi (22)
- Jérémy Breuillard (1)
- Rudolf Byker (1)
- Nick Clemens (21)
- Christophe Croullebois (1)
- Jonathan Druart (19)
- Magnus Enger (1)
- Katrin Fischer (2)
- Andrew Fuerste-Henry (1)
- Lucas Gass (3)
- David Gustafsson (2)
- Kyle M Hall (15)
- Mason James (1)
- Joonas Kylmälä (5)
- Owen Leonard (7)
- Martin Renvoize (16)
- Marcel de Rooy (8)
- Andreas Roussos (1)
- Maryse Simard (1)
- Fridolin Somers (3)
- Koha translators (1)
- Petro Vashchuk (1)
- George Veranis (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 21.05.06

- Athens County Public Libraries (7)
- BibLibre (5)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (2)
- ByWater-Solutions (40)
- Dataly Tech (2)
- Independant Individuals (9)
- Koha Community Developers (19)
- KohaAloha (1)
- Libriotech (1)
- PTFS-Europe (16)
- Rijksmuseum (8)
- Solutions inLibro inc (1)
- Theke Solutions (22)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (9)
- Nick Clemens (9)
- Jonathan Druart (90)
- Katrin Fischer (19)
- Andrew Fuerste-Henry (10)
- Lucas Gass (1)
- Victor Grousset (2)
- Kyle M Hall (126)
- Andrew Isherwood (1)
- Barbara Johnson (1)
- Joonas Kylmälä (19)
- Owen Leonard (3)
- Kelly McElligott (1)
- David Nind (32)
- Eric Phetteplace (1)
- Martin Renvoize (43)
- Marcel de Rooy (13)
- Emmi Takkinen (1)
- Petro Vashchuk (1)
- George Veranis (1)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to koha-devel@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is 21.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 24 Nov 2021 19:32:31.
