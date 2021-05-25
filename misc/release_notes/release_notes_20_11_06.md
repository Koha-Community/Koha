# RELEASE NOTES FOR KOHA 20.11.06
25 mai 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.11.06 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.11.06.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.11.06 is a bugfix/maintenance release with security fixes.

It includes 3 security fixes, 5 enhancements, 81 bugfixes.

### System requirements

These are the [recommendations for deployment](https://wiki.koha-community.org/wiki/Release_maintenance#System_requirements_and_recommendations).


## Security bugs

### Koha

- [[15720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15720) OCLC Connexion daemon does not verify username or password
- [[20982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20982) opac-shelves.pl vulnerable to Cross-site scripting attacks
- [[27942]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27942) QOTD: quote CSV uploads may contain JavaScript payloads (XSS)


## Enhancements

### Circulation

- [[21883]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21883) Show authorized value description for withdrawn in check-in

  >This adds the description of the withdrawn status to the message that is displayed when a withdrawn item is returned.

### MARC Bibliographic data support

- [[27852]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27852) Link YES_NO authorized value category to 942$n in Default framework

  >This patch adds a Yes/No drop-down menu in the default bibliographic framework for field 942$n (MARC21). This field controls whether or not the record is hidden in the OPAC.

### SIP2

- [[14300]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=14300) siplogs do not record process IDs

  >This addition to the default configuration for the SIP section of the Log4Perl configuration will add the process ID to the log lines for SIP logs.  This allows for tracing a transaction from start to finish when using forked SIP services.

### Tools

- [[25476]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25476) Uploaded files can't be easily browsed via upload.pl
- [[27594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27594) Add access to public download link for publicly-accessible uploads

  >This patch adds a link to the display of publicly-accessible downloads so that the public link can be copied.


## Critical bugs fixed

### Acquisitions

- [[27203]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27203) Order unitprice is not set anymore and  totals are 0

### Architecture, internals, and plumbing

- [[28302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28302) Koha does not work with CGI::Compile 0.24

### Cataloging

- [[18017]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18017) Use index_heading and index_match_heading in UNIMARC authorities zebra configuration
- [[24564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24564) The adding of new subfields according to IFLA updates doesn't respect existing tab

### Circulation

- [[28064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28064) Transits are not created at check in despite user responding 'Yes, print slip' to the prompt

### Database

- [[28298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28298) DBRev 19.12.00.076 broken

### OPAC

- [[28193]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28193) OpacLoginInstructions news block broken by Bug 20168

### Patrons

- [[28217]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28217) Several non-repeatable attributes when merging patrons

### REST API

- [[28248]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28248) Exception when getting all orders

### Serials

- [[27842]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27842) Incorrect biblionumber handling in serials subscriptions

### Templates

- [[28351]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28351) Cannot set restrictions when 'dateformat' is other than 'us'


## Other bugs fixed

### Acquisitions

- [[23195]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23195) Shipping costs are inconsistent in where displayed

  >With this patch the shipping costs added to an invoice are always counted as "spent". With this change the totals on the start page of the acquisition module will match the totals on the ordered and spent pages for a fund.
- [[26989]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26989) Ensure no CR occurs in an EDIFACT order message
- [[28223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28223) Total for budgets is incorrect when child funds have negative values

### Architecture, internals, and plumbing

- [[27562]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27562) itiva notices break if record title contains quotes
- [[27844]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27844) koha-worker systemd service should run as %i-koha in package install
- [[28221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28221) process_message_queue.pl missing `use Try::Tiny`
- [[28244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28244) Ukrainian is misspelled in language tables for English
- [[28276]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28276) Do not fetch config ($KOHA_CONF) from memcached
- [[28293]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28293) Wrong key used in Patrons::Import->generate_patron_attributes
- [[28367]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28367) Wrong plack condition in C4/Auth_with_shibboleth.pm

### Authentication

- [[20854]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20854) Redirect after logout with CAS 3.0 broken

  >This patch adds a new system preference casServerVersion, that will allow Koha to work correctly with different CAS protocol versions. In this case it fixes a problem that arose by changing the name of a parameter in the logout request between CAS 2 and 3 that broke the redirect after successful logout.

### Browser compatibility

- [[27282]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27282) Printing broken in some versions of Chrome

  >Printing in some versions of Google Chrome does not work correctly making it impossible to print. This patch alters the JavaScript which controls the print dialogues in order to make for a better a printing experience across all browsers.

### Cataloging

- [[23406]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=23406) When using an authorised value for suppression, record doesn't show as suppressed in staff interface
- [[27125]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27125) Show authority type for UNIMARC in authority search result display
- [[27577]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27577) Autolink bibs after generating the biblionumber
- [[27837]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27837) Permanent location is reverted to location when location updated and permanent_location mapped to MARC field
- [[28270]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28270) Wrong tooltip displayed on moredetail for the claim lost status

### Circulation

- [[16785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16785) Autocomplete broken on overdues report
- [[27836]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27836) Document that CircControl syspref changes which library's calendar to use
- [[28013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28013) Improvements to CanBookBeRenewed
- [[28139]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28139) Processing holds are not filled automatically
- [[28148]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28148) JavaScript error when printing transfer slip for existing transfer
- [[28202]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28202) Pickup libraries not sorted by name when placing hold

  >This corrects the sort order for library names for the pickup list when placing a hold. The list of libraries now sorts by library name, instead of the library code.

### Command-line Utilities

- [[27819]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27819) Spurious errors when running delete_records_via_leader.pl
- [[28028]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28028) Remove broken fix_onloan.pl maintenance script

  >This script is removed from the codebase, as it was non-functional for a long time which also suggests that it wasn't used.
- [[28255]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28255) Follow up to bug 23463 - use item_object in misc/cronjobs/delete_items.pl

### Fines and fees

- [[27811]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27811) Manage patrons fines and fees (updatecharges)  subpermissions shows links/buttons that cannot be accessed
- [[28144]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28144) Historical OVERDUE fines may not have an issue_id
- [[28181]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28181) Archived debit type still shows as available in Point of Sale
- [[28266]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28266) Misspelled word: recieved in cashup confirmation pop-up

### Hold requests

- [[25760]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=25760) Holds ratio report is not reporting on records with 1 hold
- [[28078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28078) Add option to ignore hold counts when checking CanItemBeReserved
- [[28125]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28125) All OPAC holds blocked when OPACHiddenItems contains incorrect values
- [[28286]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28286) Place hold button not displayed when biblio has only Ordered items

### MARC Authority data support

- [[28159]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28159) URI-encode existing values put into query string for z39.50 authority search

### Mana-kb

- [[27061]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27061) Double permission check in svc/mana/search

### Notices

- [[13613]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13613) Don't allow digest to be selected without a digest-able transport selected
- [[28258]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28258) Bad date formatting in AUTO_RENEWALS notice

### OPAC

- [[27566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27566) CSS rule not applying to HTML select / option -  displays with serif font ignoring rules
- [[27830]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27830) OPAC library list does not use AddressFormat
- [[28140]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28140) Accessibility: OPAC - "sort_by"  select isn't labelled on search results page
- [[28241]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28241) OPACNoResultsFound {QUERY_KW} placeholder doesn't always match the search terms when commas are included in the search

### Patrons

- [[26940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26940) debarred comment in borrowers table is lost on patron modifications in memberentry.pl page

### Plugin architecture

- [[27114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27114) Use Template Toolkit plugin for Koha plugins hook 'intranet_catalog_biblio_tab'

  >Koha plugins hook 'intranet_catalog_biblio_tab' now uses Template Toolkit plugin (like hook 'intranet_js', ...).
  >It makes it easy to use it in other places (like MARC details page for example).
- [[27120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27120) Send biblio to Koha plugins hook 'intranet_catalog_biblio_tab'

### SIP2

- [[28320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28320) SIP SC Status message should check the DB connection

### Searching

- [[26533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26533) Searching authorities using 'is exactly' doesn't work as expected

  **Sponsored by** *Education Services Australia SCIS*

  >Searching authorities using 'is exactly' was matching on any word in the heading. Now it is matching the heading exactly (the entire heading).
- [[28213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28213) Deleting a patron or patron club causes server error on searching

### Searching - Elasticsearch

- [[27724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27724) Use lenient also in Elasticsearch authorities search
- [[28268]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28268) Improve memory usage when indexing authorities in Elasticsearch

### Staff Client

- [[28187]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28187) rowGroup headings are getting their styles overriden

### System Administration

- [[27968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27968) MARC framework CSV and ODS import incomplete or corrupted
- [[28207]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28207) Crash when seeing MARC structure of a new framework
- [[28345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28345) Patron attributes no longer have option to select empty class

### Templates

- [[26471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26471) Datatables js error on missing pdfmake.min.js.map
- [[27232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27232) Missing spaces in member-alt-contact-style.inc make some strings appearing twice in po
- [[27277]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27277) Queued vs Enqueued
- [[27695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27695) Fix style of messages on Elasticsearch configuration page
- [[27827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27827) Authority type input field for new authority types should be wider
- [[27861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27861) Warning in C4/XSLT.pm - use of uninitialized value in numeric eq (==)
- [[28190]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28190) Library limitation column not toggable on itemtypes table

### Test Suite

- [[26405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26405) Circulation.t fails on 'AddRenewal left both fines'
- [[28234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28234) TestBuilder->build_sample_biblio does not deal correctly with encoding
- [[28249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28249) Selenium->wait_for_element_visible can fall in an infinite loop
- [[28250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28250) Debug from Selenium error handler is no longer working
- [[28288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28288) XISBN.t is failing is 500 is returned by the webservice

### Tools

- [[21818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21818) Don't use AutoCommit flag in stage-marc-import.pl
- [[28170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28170) Downloading some files via Tools - Upload is broken
- [[28178]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28178) Image viewer does not select the correct image

  **Sponsored by** *Gerhard Sondermann Dialog e.K. (presseplus.de, presseshop.at, presseshop.ch)*
- [[28229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28229) Hide clubs from place a hold screen if no clubs exist
## New sysprefs

- casServerVersion

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, the Koha manual is available in the following languages:

- [English](http://koha-community.org/manual/20.11/en/html/)
- [Arabic](http://koha-community.org/manual/20.11/ar/html/)
- [Chinese - Taiwan](http://koha-community.org/manual/20.11/zh_TW/html/)
- [Czech](http://koha-community.org/manual/20.11/cs/html/)
- [French](http://koha-community.org/manual/20.11/fr/html/)
- [French (Canada)](http://koha-community.org/manual/20.11/fr_CA/html/)
- [German](http://koha-community.org/manual/20.11/de/html/)
- [Hindi](http://koha-community.org/manual/20.11/hi/html/)
- [Italian](http://koha-community.org/manual/20.11/it/html/)
- [Portuguese - Brazil](http://koha-community.org/manual/20.11/pt_BR/html/)
- [Spanish](http://koha-community.org/manual/20.11/es/html/)
- [Turkish](http://koha-community.org/manual/20.11/tr/html/)

The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (99.5%)
- Armenian (100%)
- Armenian (Classical) (89%)
- Catalan; Valencian (54.4%)
- Chinese (Taiwan) (91.1%)
- Czech (73%)
- English (New Zealand) (59.6%)
- English (USA)
- Finnish (79.3%)
- French (89.3%)
- French (Canada) (91.1%)
- German (100%)
- German (Switzerland) (66.9%)
- Greek (60.7%)
- Hindi (100%)
- Italian (100%)
- Nederlands-Nederland (Dutch-The Netherlands) (70.9%)
- Norwegian Bokmål (63.8%)
- Polish (92%)
- Portuguese (88.5%)
- Portuguese (Brazil) (95.9%)
- Russian (94%)
- Slovak (80.7%)
- Spanish (99.1%)
- Swedish (74.5%)
- Telugu (100%)
- Turkish (98.2%)
- Ukrainian (65.5%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.11.06 is


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
  - Kyle Hall
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
We thank the following libraries who are known to have sponsored
new features in Koha 20.11.06:

- Education Services Australia SCIS
- Gerhard Sondermann Dialog e.K. (presseplus.de, presseshop.at, presseshop.ch)

We thank the following individuals who contributed patches to Koha 20.11.06.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (6)
- Alex Arnaud (1)
- Henry Bolshaw (1)
- Colin Campbell (1)
- Nick Clemens (31)
- David Cook (3)
- Jonathan Druart (38)
- Katrin Fischer (1)
- Lucas Gass (6)
- Didier Gautheron (1)
- Victor Grousset (3)
- Kyle M Hall (8)
- Mason James (2)
- Joonas Kylmälä (4)
- Owen Leonard (13)
- Ere Maijala (1)
- Julian Maurice (4)
- Matthias Meusburger (1)
- James O'Keeffe (2)
- Martin Renvoize (7)
- Phil Ringnalda (1)
- Caroline Cyr La Rose (1)
- Andreas Roussos (2)
- Fridolin Somers (22)
- Emmi Takkinen (1)
- Lari Taskula (1)
- Koha Translators (1)
- Petro Vashchuk (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.11.06

- Athens County Public Libraries (13)
- BibLibre (29)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (1)
- ByWater-Solutions (45)
- Catalyst Open Source Academy (1)
- Chetco Community Public Library (1)
- Dataly Tech (2)
- Hypernova Oy (1)
- Independant Individuals (4)
- Koha Community Developers (41)
- KohaAloha (2)
- Prosentient Systems (3)
- PTFS-Europe (8)
- Solutions inLibro inc (1)
- Theke Solutions (6)
- UK Parliament (1)
- University of Helsinki (5)

We also especially thank the following individuals who tested patches
for Koha.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (13)
- Marjorie Barry-Vila (1)
- Allison Blanning (1)
- Henry Bolshaw (2)
- Sonia Bouis (2)
- Galen Charlton (1)
- Nick Clemens (20)
- David Cook (2)
- Michal Denar (1)
- Jonathan Druart (130)
- Katrin Fischer (31)
- Andrew Fuerste-Henry (5)
- Lucas Gass (3)
- Victor Grousset (21)
- Amit Gupta (1)
- Kyle M Hall (28)
- Katariina Hanhisalo (3)
- Frank Hansen (1)
- Sally Healey (4)
- Mazen Khallaf (1)
- Rhonda Kuiper (2)
- Joonas Kylmälä (7)
- Owen Leonard (24)
- Julian Maurice (6)
- David Nind (20)
- Séverine Queune (4)
- Martin Renvoize (40)
- Phil Ringnalda (3)
- Marcel de Rooy (2)
- Andreas Roussos (1)
- Lisette Scheer (1)
- Fridolin Somers (139)
- Lyon 3 Team (1)
- Petro Vashchuk (3)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

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

Autogenerated release notes updated last on 25 mai 2021 13:28:35.
