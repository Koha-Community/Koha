# RELEASE NOTES FOR KOHA 20.11.12
30 nov. 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.11.12 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.11.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.12 is a bugfix/maintenance release.

It includes 2 enhancements, 41 bugfixes.

### System requirements

You can learn about the system components (like OS and database) needed for running Koha here: https://wiki.koha-community.org/wiki/System_requirements_and_recommendations




## Enhancements

### Plugin architecture

- [[27173]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27173) Add plugin hooks for authority record changes

  >This enhancement allows plugin authors to implement an `after_authority_action` method in order to act upon authority create, modify and delete.
- [[28474]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28474) Pass process_message_queue.pl params to before_send_messages plugin hooks

  >This enhancement passes the parameters received by process_message_queue.pl through to the before_send_messages plugin calls. This allows plugins to respect calls that should only affect certain letter codes etc.


## Critical bugs fixed

### Acquisitions

- [[14999]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14999) Adding to basket orders from staged files mixes up the prices between different orders
- [[29283]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29283) Cannot delete basket with cancelled order for deleted biblio

### Architecture, internals, and plumbing

- [[26374]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26374) Update for 19974 is not idempotent
- [[29386]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29386) background jobs table data field is a TEXT which is too small

### Circulation

- [[29255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29255) Built-in offline circulation broken with SQL error

### Notices

- [[28803]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28803) process_message_queue.pl dies if any messsages in the message queue contain an invalid to_address

### OPAC

- [[28870]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28870) Cart shipping fails because of Non-ASCII characters in display-name of reply-to address
- [[29416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29416) Regression: information from existing bib no longer populating on suggest for purchase

  >This restores the behaviour for purchase suggestions for an existing title, so that the suggestion form is pre-filled with the details from the existing record.

### Patrons

- [[29341]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29341) If OpacRenewalBranch = opacrenew, pseudonymization process leads to "internal server error" when patrons renew the loans at OPAC
- [[29524]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29524) Cannot set a new value for privacy_guarantor_checkouts in memberentry.pl

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
- [[29564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29564) Use List::MoreUtils so SIP U16/Xenial does not break

### System Administration

- [[28729]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28729) Return-path header not set in emails


## Other bugs fixed

### About

- [[28904]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28904) Update information on Newsletter editor on about page
- [[29300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29300) Release team 22.05

### Acquisitions

- [[27708]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27708) Cannot create EDI order if AcqCreateItem value is not "placing an order"
- [[28627]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28627) Revert the order receive page to display 'Actual cost' as ecost_tax_included/ecost_tax_excluded if unitprice not set

### Architecture, internals, and plumbing

- [[29321]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29321) Remove a last without loop context
- [[29350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29350) TT method 'delete' don't need to be escaped

### Label/patron card printing

- [[25459]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25459) In patron cards layout, barcode position doesn't respect units

### OPAC

- [[28768]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28768) OPAC reading history page (opac-readingrecord.pl) wont display news items
- [[29329]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29329) stray "s" in opac-detail

### Patrons

- [[27145]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27145) Patron deletion via intranet doesn't handle exceptions well
- [[28973]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28973) Improve Koha::Patron::can_see_patron_infos efficiency
- [[29213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29213) Typo ol in member-alt-contact-style.inc
- [[29227]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29227) Patron messaging preferences digest show as editable but are not

### REST API

- [[29405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29405) The patron spec for date_renewed is missing it's format definition

  >This fix adds the date format string to the date_renewed field. This is to ensure that the date_renewed field can be correctly validated.

### Reports

- [[27884]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27884) Add HTML mail support for patron emailer script

### SIP2

- [[29452]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29452) Unnecessary warns in sip logs

### Searching

- [[28365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28365) (Bug 19873 follow-up) Make it possible to search on value 0

### Staff Client

- [[29195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29195) Highlighting broken on odd rows in circ-patron-search-results

### System Administration

- [[29075]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29075) OPAC info should not be displayed in libraries table

### Templates

- [[28470]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28470) Typo: Are you sure you with to chart this report?
- [[28579]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28579) Typo: No record have been imported because they all match an existing record in your catalog.
- [[29286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29286) Typo: Librarien will need the manage_auth_values subpermission.

### Test Suite

- [[29306]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29306) Holds.t: Fix Use of uninitialized value $_ in concatenation (.) or string
- [[29315]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29315) Remove warnings from Search.t
- [[29363]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29363) TestBuilder.t failing if biblionumber=123 does not exist
- [[29364]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=29364) Search.t not reverting changes made to the framework



## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha
documentation is

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:


- [Arabic](https://koha-community.org/manual/20.11/ar/html/) (27%)
- [Chinese (Taiwan)](https://koha-community.org/manual/20.11/zh_TW/html/) (61.4%)
- [English (USA)](https://koha-community.org/manual/20.11/en/html/)
- [French](https://koha-community.org/manual/20.11/fr/html/) (52.7%)
- [French (Canada)](https://koha-community.org/manual/20.11/fr_CA/html/) (26%)
- [German](https://koha-community.org/manual/20.11/de/html/) (71.2%)
- [Hindi](https://koha-community.org/manual/20.11/hi/html/) (99.9%)
- [Italian](https://koha-community.org/manual/20.11/it/html/) (50%)
- [Spanish](https://koha-community.org/manual/20.11/es/html/) (36.5%)
- [Turkish](https://koha-community.org/manual/20.11/tr/html/) (41.9%)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)


## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Bulgarian (91.3%)
- Catalan; Valencian (57.6%)
- Chinese (Taiwan) (92.9%)
- Czech (73.2%)
- English (New Zealand) (59.4%)
- English (USA)
- Finnish (79.2%)
- French (91.3%)
- French (Canada) (91.9%)
- German (100%)
- German (Switzerland) (66.7%)
- Greek (60.5%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (88.3%)
- Norwegian Bokmål (63.6%)
- Polish (100%)
- Portuguese (88.4%)
- Portuguese (Brazil) (96.4%)
- Russian (93.5%)
- Slovak (80.3%)
- Spanish (98.9%)
- Swedish (75%)
- Telugu (99.9%)
- Turkish (99.9%)
- Ukrainian (70.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.12 is


- Release Manager: Jonathan Druart

- Release Manager assistants:
  - Martin Renvoize
  - Tomás Cohen Arazi

- QA Manager: Katrin Fischer

- QA Team:
  - David Cook
  - Agustín Moyano
  - Martin Renvoize
  - Marcel de Rooy
  - Joonas Kylmälä
  - Julian Maurice
  - Tomás Cohen Arazi
  - Josef Moravec
  - Nick Clemens
  - Kyle M Hall
  - Victor Grousset

- Topic Experts:
  - UI Design -- Owen Leonard
  - REST API -- Tomás Cohen Arazi
  - Zebra -- Fridolin Somers
  - Accounts -- Martin Renvoize

- Bug Wranglers:
  - Amit Gupta
  - Mengü Yazıcıoğlu
  - Indranil Das Gupta

- Packaging Managers:
  - David Cook
  - Mason James
  - Agustín Moyano

- Documentation Manager: Caroline Cyr La Rose


- Documentation Team:
  - Marie-Luce Laflamme
  - Lucy Vaux-Harvey
  - Henry Bolshaw
  - David Nind

- Translation Managers: 
  - Indranil Das Gupta
  - Bernardo González Kriegel

- Release Maintainers:
  - 20.11 -- Fridolin Somers
  - 20.05 -- Andrew Fuerste-Henry
  - 19.11 -- Victor Grousset

## Credits

We thank the following individuals who contributed patches to Koha 20.11.12

- Tomás Cohen Arazi (3)
- Jérémy Breuillard (1)
- Nick Clemens (5)
- Christophe Croullebois (1)
- Jonathan Druart (13)
- Lucas Gass (2)
- Didier Gautheron (1)
- Victor Grousset (1)
- David Gustafsson (2)
- Kyle M Hall (7)
- Mason James (1)
- Joonas Kylmälä (5)
- Owen Leonard (5)
- Martin Renvoize (9)
- Marcel de Rooy (4)
- Maryse Simard (1)
- Fridolin Somers (9)
- Koha translators (1)
- Petro Vashchuk (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.12

- Athens County Public Libraries (5)
- BibLibre (12)
- ByWater-Solutions (14)
- Independant Individuals (8)
- Koha Community Developers (14)
- KohaAloha (1)
- PTFS-Europe (9)
- Rijksmuseum (4)
- Solutions inLibro inc (1)
- Theke Solutions (3)

We also especially thank the following individuals who tested patches
for Koha

- Tomás Cohen Arazi (5)
- Nick Clemens (9)
- Jonathan Druart (44)
- Katrin Fischer (10)
- Andrew Fuerste-Henry (3)
- Lucas Gass (1)
- Victor Grousset (1)
- Kyle M Hall (56)
- Andrew Isherwood (1)
- Joonas Kylmälä (10)
- Owen Leonard (2)
- David Nind (21)
- Martin Renvoize (23)
- Marcel de Rooy (7)
- Fridolin Somers (61)
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
line is 20.11.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 30 nov. 2021 06:50:42.
