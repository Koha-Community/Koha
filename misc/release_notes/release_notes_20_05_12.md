# RELEASE NOTES FOR KOHA 20.05.12
25 May 2021

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 20.05.12 can be downloaded from:

- [Download](http://download.koha-community.org/koha-20.05.12.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 20.05.12 is a bugfix/maintenance release with security fixes.

It includes 3 security fixes, 1 enhancements, 64 bugfixes.

### System requirements

Koha is continuously tested against the following configurations and as such these are the recommendations for 
deployment: 

- Debian Jessie with MySQL 5.5 (End of life)
- Debian Stretch with MariaDB 10.1
- Debian Buster with MariaDB 10.3
- Ubuntu Bionic with MariaDB 10.1 
- Debian Stretch with MySQL 8.0 (Experimental MySQL 8.0 support)

Additional notes:
    
- Perl 5.10 is required (5.24 is recommended)
- Zebra or Elasticsearch is required


## Security bugs

### Koha

- [[15720]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15720) OCLC Connexion daemon does not verify username or password
- [[20982]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20982) opac-shelves.pl vulnerable to Cross-site scripting attacks
- [[27942]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27942) QOTD: quote CSV uploads may contain JavaScript payloads (XSS)


## Enhancements

### Tools

- [[27594]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27594) Add access to public download link for publicly-accessible uploads

  >This patch adds a link to the display of publicly-accessible downloads so that the public link can be copied.


## Critical bugs fixed

### Acquisitions

- [[27203]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27203) Order unitprice is not set anymore and  totals are 0

### Architecture, internals, and plumbing

- [[28302]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28302) Koha does not work with CGI::Compile 0.24

### Cataloging

- [[24564]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=24564) The adding of new subfields according to IFLA updates doesn't respect existing tab

### Circulation

- [[28064]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28064) Transits are not created at check in despite user responding 'Yes, print slip' to the prompt

### Database

- [[28298]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28298) DBRev 19.12.00.076 broken

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
- [[28221]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28221) process_message_queue.pl missing `use Try::Tiny`
- [[28244]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28244) Ukrainian is misspelled in language tables for English
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
- [[27577]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27577) Autolink bibs after generating the biblionumber
- [[27837]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27837) Permanent location is reverted to location when location updated and permanent_location mapped to MARC field

### Circulation

- [[27836]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27836) Document that CircControl syspref changes which library's calendar to use
- [[28013]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28013) Improvements to CanBookBeRenewed
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

### MARC Authority data support

- [[28159]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28159) URI-encode existing values put into query string for z39.50 authority search

### Mana-kb

- [[27061]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27061) Double permission check in svc/mana/search

### Notices

- [[28258]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28258) Bad date formatting in AUTO_RENEWALS notice

### OPAC

- [[27566]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27566) CSS rule not applying to HTML select / option -  displays with serif font ignoring rules
- [[28241]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28241) OPACNoResultsFound {QUERY_KW} placeholder doesn't always match the search terms when commas are included in the search

### Patrons

- [[26940]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26940) debarred comment in borrowers table is lost on patron modifications in memberentry.pl page

### Plugin architecture

- [[27114]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27114) Use Template Toolkit plugin for Koha plugins hook 'intranet_catalog_biblio_tab'

  >Koha plugins hook 'intranet_catalog_biblio_tab' now uses Template Toolkit plugin (like hook 'intranet_js', ...).
  >It makes it easy to use it in other places (like MARC details page for example).
- [[27120]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27120) Send biblio to Koha plugins hook 'intranet_catalog_biblio_tab'

### SIP2

- [[28054]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28054) SIPServer.pm is a program and requires a shebang
- [[28320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28320) SIP SC Status message should check the DB connection

### Searching

- [[26533]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26533) Searching authorities using 'is exactly' doesn't work as expected

  **Sponsored by** *Education Services Australia SCIS*

  >Searching authorities using 'is exactly' was matching on any word in the heading. Now it is matching the heading exactly (the entire heading).
- [[28213]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28213) Deleting a patron or patron club causes server error on searching

### Searching - Elasticsearch

- [[27724]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27724) Use lenient also in Elasticsearch authorities search

### System Administration

- [[27968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27968) MARC framework CSV and ODS import incomplete or corrupted
- [[28207]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28207) Crash when seeing MARC structure of a new framework
- [[28345]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28345) Patron attributes no longer have option to select empty class

### Templates

- [[26471]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26471) Datatables js error on missing pdfmake.min.js.map
- [[27232]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27232) Missing spaces in member-alt-contact-style.inc make some strings appearing twice in po
- [[27695]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27695) Fix style of messages on Elasticsearch configuration page
- [[27827]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27827) Authority type input field for new authority types should be wider
- [[27861]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=27861) Warning in C4/XSLT.pm - use of uninitialized value in numeric eq (==)

### Test Suite

- [[26405]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=26405) Circulation.t fails on 'AddRenewal left both fines'
- [[28234]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28234) TestBuilder->build_sample_biblio does not deal correctly with encoding
- [[28249]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28249) Selenium->wait_for_element_visible can fall in an infinite loop
- [[28250]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28250) Debug from Selenium error handler is no longer working
- [[28288]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28288) XISBN.t is failing is 500 is returned by the webservice

### Tools

- [[21818]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21818) Don't use AutoCommit flag in stage-marc-import.pl
- [[28170]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28170) Downloading some files via Tools - Upload is broken
- [[28229]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=28229) Hide clubs from place a hold screen if no clubs exist
## New sysprefs

- casServerVersion

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/20.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (98.6%)
- Armenian (100%)
- Armenian (Classical) (99.7%)
- Chinese (Taiwan) (94.2%)
- Czech (80.8%)
- English (New Zealand) (66.6%)
- English (USA)
- Finnish (70.4%)
- French (86.2%)
- French (Canada) (97.2%)
- German (100%)
- German (Switzerland) (74.4%)
- Greek (62.1%)
- Hindi (100%)
- Italian (100%)
- Norwegian Bokmål (71%)
- Polish (79.5%)
- Portuguese (86.6%)
- Portuguese (Brazil) (97.9%)
- Russian (86.5%)
- Slovak (89.6%)
- Spanish (100%)
- Swedish (79.5%)
- Telugu (100%)
- Turkish (100%)
- Ukrainian (66.3%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 20.05.12 is


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
new features in Koha 20.05.12:

- Education Services Australia SCIS

We thank the following individuals who contributed patches to Koha 20.05.12.

- Aleisha Amohia (1)
- Tomás Cohen Arazi (5)
- Alex Arnaud (1)
- Colin Campbell (1)
- Nick Clemens (27)
- David Cook (1)
- Jonathan Druart (27)
- Katrin Fischer (1)
- Andrew Fuerste-Henry (8)
- Lucas Gass (6)
- Didier Gautheron (1)
- Victor Grousset (4)
- Kyle M Hall (7)
- Mason James (2)
- Joonas Kylmälä (2)
- Owen Leonard (7)
- Julian Maurice (3)
- Matthias Meusburger (1)
- Martin Renvoize (4)
- Phil Ringnalda (1)
- Andreas Roussos (2)
- Fridolin Somers (9)
- Emmi Takkinen (1)
- Lari Taskula (1)
- Koha Translators (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 20.05.12

- Athens County Public Libraries (7)
- BibLibre (15)
- Bibliotheksservice-Zentrum Baden-Württemberg (BSZ) (1)
- ByWater-Solutions (48)
- Chetco Community Public Library (1)
- Dataly Tech (2)
- Hypernova Oy (1)
- Independant Individuals (2)
- Koha Community Developers (31)
- KohaAloha (2)
- Prosentient Systems (1)
- PTFS-Europe (5)
- Theke Solutions (5)
- University of Helsinki (2)

We also especially thank the following individuals who tested patches
for Koha.

- Tomás Cohen Arazi (10)
- Marjorie Barry-Vila (1)
- Allison Blanning (1)
- Henry Bolshaw (2)
- Sonia Bouis (2)
- Galen Charlton (1)
- Nick Clemens (14)
- David Cook (2)
- Michal Denar (1)
- Jonathan Druart (97)
- Katrin Fischer (21)
- Andrew Fuerste-Henry (117)
- Lucas Gass (2)
- Victor Grousset (17)
- Amit Gupta (1)
- Kyle M Hall (19)
- Katariina Hanhisalo (3)
- Frank Hansen (1)
- Sally Healey (3)
- Rhonda Kuiper (2)
- Joonas Kylmälä (7)
- Owen Leonard (15)
- Julian Maurice (4)
- David Nind (13)
- Séverine Queune (4)
- Martin Renvoize (33)
- Phil Ringnalda (3)
- Marcel de Rooy (1)
- Lisette Scheer (1)
- Fridolin Somers (102)
- Lyon 3 Team (1)
- Petro Vashchuk (2)



We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](https://git.koha-community.org/koha-community/koha)

The branch for this version of Koha and future bugfixes in this release
line is rmain2005.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 25 May 2021 15:13:43.
