# RELEASE NOTES FOR KOHA 18.05.05
23 Oct 2018

Koha is the first free and open source software library automation
package (ILS). Development is sponsored by libraries of varying types
and sizes, volunteers, and support companies from around the world. The
website for the Koha project is:

- [Koha Community](http://koha-community.org)

Koha 18.05.05 can be downloaded from:

- [Download](http://download.koha-community.org/koha-18.05.05.tar.gz)

Installation instructions can be found at:

- [Koha Wiki](http://wiki.koha-community.org/wiki/Installation_Documentation)
- OR in the INSTALL files that come in the tarball

Koha 18.05.05 is a bugfix/maintenance release.

It includes 3 enhancements, 67 bugfixes.




## Enhancements

### Architecture, internals, and plumbing

- [[20669]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20669) Add upgrade method to plugins

> This enhancement standardises the methods used by plugin authors to maintain their plugin data across plugin versions.


- [[21352]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21352) Allow plugins to add CSS and Javascript to Staff interface

> This enhancement allows plugin authors to make adaptations to the staff client using css and javascript.




## Critical bugs fixed

### Acquisitions

- [[21385]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21385) Vendor search: Item count is incorrectly updated on partial receive

### Architecture, internals, and plumbing

- [[21133]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21133) Missing use C4::Accounts statement in Koha/Patron.pm
- [[21432]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21432) Internal Server Error in Checkout History

### Cataloging

- [[21448]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21448) Field 606 doesn't add multiple x subfields

### Circulation

- [[10382]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=10382) collection not returning to null when removed from course reserves
- [[21176]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21176) decreaseLoanHighHolds does not properly calculate date when  TimeFormat set to 12 hour
- [[21464]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21464) Overdues export is missing lot of fields

### Installation and upgrade (command-line installer)

- [[16690]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16690) Improve security of remote database installations
- [[21440]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21440) koha-create expects the file passed by $DEFAULTSQL to be in gzip format

> Add support to koha-create to allow it to accept both compressed and uncompressed files for DEFAULTSQL



### Label/patron card printing

- [[21281]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21281) Label Template - Creation not working

### OPAC

- [[21479]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21479) Removing from cart removes 2 items

### translate.koha-community.org

- [[21480]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21480) misc/translator/translate does not work with perl 5.26


## Other bugs fixed

### About

- [[7143]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=7143) Bug for tracking changes to the about page

### Acquisitions

- [[16739]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16739) Generate EDIFACT on basket groups falsely showing when configuration is incomplete
- [[19271]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19271) Ordered/Spent lists should display vendor name, not vendor code
- [[21398]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21398) Search term when adding an order from an existing record should be required
- [[21417]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21417) EDI ordering fails when basket and EAN libraries do not match
- [[21425]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21425) basketno not being interpolated into error message
- [[21537]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21537) Template error when creating a new order from a suggestion

### Architecture, internals, and plumbing

- [[15734]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15734) Audio Alerts broken
- [[19687]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19687) Recent upgrade to 17.05.04.000 bulkmarcimport started to fail
- [[21115]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21115) Add multi_param call and add divider in cache key in svc/report and opac counterpart
- [[21396]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21396) Missing use statements in Koha::Account
- [[21500]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21500) Warnings in rotating collections

### Authentication

- [[20023]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20023) Password recovery should be case insensitive
- [[21323]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21323) Redirect page after login missing multiple params

### Cataloging

- [[18655]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=18655) Unimarc field 210c fails on importing fields with a simple quote
- [[20785]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20785) Advanced Editor does not honor MarcFieldDocURL
- [[21362]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21362) Advanced MARC Editor - Rancor - Tab navigation not working in fixed fields
- [[21365]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21365) BiblioAddsAuthorities does not work with the Advanced MARC Editor - Rancor
- [[21407]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21407) Can't enter new macros in the advanced cataloging editor (rancor)

### Circulation

- [[16420]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=16420) Buttons inconsistent between "Hold found" and "Hold found (waiting)" dialogs in checkin
- [[21463]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21463) Library is no longer displayed in the overdue list

### Command-line Utilities

- [[21322]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21322) process_message_queue.pl --type should take an argument

### Database

- [[5458]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=5458) length of items.ccode disagrees with authorised_values.authorised_value

### Fines and fees

- [[21167]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21167) Correct price formatting on printed fee receipt and invoice
- [[21196]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21196) Allow calcfine to consider default item type replacement cost

### Hold requests

- [[21320]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21320) Holds to pull should honor syspref AllowHoldsOnDamagedItems
- [[21389]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21389) Javascript error on article requests page bis

### I18N/L10N

- [[19500]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=19500) Make module names on letters overview page translatable

### ILL

- [[20548]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20548) Remove copyright clearance workflow from staff created ILL requests
- [[21289]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21289) Error when sending emails to partner libraries

### Installation and upgrade (command-line installer)

- [[21426]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21426) setting USE_MEMCACHED to "no" in koha-sites.conf does not have any effect

### Lists

- [[21297]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21297) "More lists" screen missing "Select an Existing list" fieldset when all lists are public

### MARC Bibliographic data support

- [[20910]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20910) 773$g not displayed if $0 is present

> Sponsored-by: Escuela de Orientacion Lacaniana



### Notices

- [[15971]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=15971) Serial claim letters should allow the use of all biblio and biblioitems fields (like issn)

### OPAC

- [[21078]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21078) Overdrive JS breaks when window opened from another site
- [[21493]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21493) Remove incomplete icon style from serial issues tabs

### Packaging

- [[17237]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=17237) Stop koha-create from creating MySQL users without host restriction

### Patrons

- [[20656]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20656) Print summary for patron shows paid fines and formats payments badly

> Print summary for patron will now show only outstanding fines/payments. To print all fines/payments you can use the 'print' option for the table in the accounts page for the patron.


- [[21353]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21353) Merge patrons option only available with manage_patron_lists

### Searching

- [[9968]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=9968) Incorrect index used for 'Standard number' in advanced search
- [[20151]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20151) Search is broken when stemming has no language
- [[21455]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21455) Authority search options get shuffled around when you click on 'Search'

### Searching - Zebra

- [[21416]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21416) 'gr' option missing from ZEBRA_LANGUAGE options in koha-sites.conf

### Serials

- [[20241]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20241) Fix display of publication year in subscription record search for MARC21

### Staff Client

- [[21291]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21291) Article requests page doesn't show MARC, LabeledMARC and ISBD in sidebar

### System Administration

- [[21279]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21279) Transport cost matrix shows html entity in all empty cells

### Templates

- [[13272]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=13272) Many inputs lack a type attribute
- [[20223]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20223) Merge members-menu and circ-menu inc files
- [[21350]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21350) Add Font Awesome icon for pending onsite checkouts link
- [[21397]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21397) Routing list tab not marked as active
- [[21506]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21506) DataTables four button pagination uses the wrong icon for First and Last buttons
- [[21550]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21550) DataTables four button pagination uses the wrong icon for disabled buttons

### Test Suite

- [[20177]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20177) Remove GROUP BY clause in GetCourses

### Tools

- [[20131]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=20131) Inventory optional filters always shows "For loan" for value 0
- [[21113]](http://bugs.koha-community.org/bugzilla3/show_bug.cgi?id=21113) Hint Messages are misleading at "Merge Selected Patrons" in Patron Lists



## System requirements

Important notes:
    
- Perl 5.10 is required
- Zebra is required

## Documentation

The Koha manual is maintained in Sphinx. The home page for Koha 
documentation is 

- [Koha Documentation](http://koha-community.org/documentation/)

As of the date of these release notes, only the English version of the
Koha manual is available:

- [Koha Manual](http://koha-community.org/manual/18.05/en/html/)


The Git repository for the Koha manual can be found at

- [Koha Git Repository](https://gitlab.com/koha-community/koha-manual)

## Translations

Complete or near-complete translations of the OPAC and staff
interface are available in this release for the following languages:

- Arabic (100%)
- Armenian (100%)
- Basque (73.4%)
- Chinese (China) (77.9%)
- Chinese (Taiwan) (100%)
- Czech (93.5%)
- Danish (64.3%)
- English (New Zealand) (96.7%)
- English (USA)
- Finnish (93.6%)
- French (100%)
- French (Canada) (94.8%)
- German (100%)
- German (Switzerland) (99.7%)
- Greek (80.9%)
- Hindi (100%)
- Italian (98.6%)
- Norwegian Bokmål (68.7%)
- Occitan (post 1500) (71.1%)
- Persian (53.4%)
- Polish (94.8%)
- Portuguese (100%)
- Portuguese (Brazil) (84.8%)
- Slovak (95.5%)
- Spanish (100%)
- Swedish (95%)
- Turkish (100%)
- Vietnamese (65.8%)

Partial translations are available for various other languages.

The Koha team welcomes additional translations; please see

- [Koha Translation Info](http://wiki.koha-community.org/wiki/Translating_Koha)

For information about translating Koha, and join the koha-translate 
list to volunteer:

- [Koha Translate List](http://lists.koha-community.org/cgi-bin/mailman/listinfo/koha-translate)

The most up-to-date translations can be found at:

- [Koha Translation](http://translate.koha-community.org/)

## Release Team

The release team for Koha 18.05.05 is

- Release Manager: [Nick Clemens](mailto:nick@bywatersolutions.com)
- Release Manager assistants:
  - [Brendan Gallagher](mailto:brendan@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)

- Module Maintainers:
  - REST API -- [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - Elasticsearch -- [Nick Clemens](mailto:nick@bywatersolutions.com)
- QA Manager: [Katrin Fischer](mailto:Katrin.Fischer@bsz-bw.de)

- QA Team:
  - [Julian Maurice](mailto:julian.maurice@biblibre.com)
  - [Marcel de Rooy](mailto:m.de.rooy@rijksmuseum.nl)
  - Josef Moravec
  - [Alex Arnaud](mailto:alex.arnaud@biblibre.com)
  - [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - [Tomás Cohen Arazi](mailto:tomascohen@gmail.com)
  - [Kyle Hall](mailto:kyle@bywatersolutions.com)
  - [Jonathan Druart](mailto:jonathan.druart@bugs.koha-community.org)
  - [Chris Cormack](mailto:chrisc@catalyst.net.nz)
- Bug Wranglers:
  - Claire Gravely
  - Jon Knight
  - [Indranil Das Gupta](mailto:indradg@l2c2.co.inc)
  - [Amit Gupta](mailto:amitddng135@gmail.com)
- Packaging Manager: [Mirko Tietgen](mailto:mirko@abunchofthings.net)
- Documentation Team:
  - Lee Jamison
  - David Nind
  - Caroline Cyr La Rose
- Translation Manager: [Bernardo Gonzalez Kriegel](mailto:bgkriegel@gmail.com)
- Release Maintainers:
  - 18.05 -- [Martin Renvoize](mailto:martin.renvoize@ptfs-europe.com)
  - 17.11 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)
  - 17.05 -- [Fridolin Somers](mailto:fridolin.somers@biblibre.com)

## Credits
We thank the following libraries who are known to have sponsored
new features in Koha 18.05.05:

- Escuela de Orientacion Lacaniana
- Gothenburg University Library

We thank the following individuals who contributed patches to Koha 18.05.05.

- Alberto (1)
- Blou (3)
- Alex Arnaud (2)
- Christopher Brannon (1)
- Colin Campbell (2)
- Nick Clemens (10)
- Tomás Cohen Arazi (2)
- Marcel de Rooy (4)
- Jonathan Druart (26)
- Magnus Enger (1)
- Katrin Fischer (5)
- David Gustafsson (1)
- Andrew Isherwood (3)
- Pasi Kallinen (1)
- Olli-Antti Kivilahti (1)
- Jon Knight (1)
- Owen Leonard (6)
- Ere Maijala (2)
- Kyle M Hall (5)
- Josef Moravec (2)
- Dobrica Pavlinusic (1)
- Martin Renvoize (12)
- Andreas Roussos (4)
- Fridolin Somers (4)
- Mark Tompsett (6)
- Koha translators (1)
- Baptiste Wojtkowski (1)

We thank the following libraries, companies, and other institutions who contributed
patches to Koha 18.05.05

-  (0)
- ACPL (6)
- BibLibre (7)
- BSZ BW (5)
- bugs.koha-community.org (26)
- ByWater-Solutions (12)
- bywatersolutiosn.com (2)
- bywatetsolutions.com (1)
- cdalibrary.org (1)
- Göteborgs universitet (1)
- helsinki.fi (3)
- icloud.com (1)
- joensuu.fi (1)
- Libriotech (1)
- Loughborough University (1)
- PTFS-Europe (17)
- Rijksmuseum (4)
- rot13.org (1)
- Solutions inLibro inc (3)
- Theke Solutions (2)
- unidentified (12)

We also especially thank the following individuals who tested patches
for Koha.

- Claudio (1)
- José Anjos (1)
- Colin Campbell (1)
- Barry Cannon (2)
- Nick Clemens (92)
- Tomas Cohen Arazi (11)
- Chris Cormack (19)
- Caroline Cyr La rose (2)
- Caroline Cyr La Rose (5)
- Michal Denar (11)
- Marcel de Rooy (11)
- Jonathan Druart (23)
- Katrin Fischer (21)
- Brendan Gallagher (1)
- Claire Gravely (2)
- Dilan Johnpullé (1)
- Pasi Kallinen (1)
- Owen Leonard (11)
- Jesse Maseto (1)
- Julian Maurice (5)
- Kyle M Hall (3)
- Josef Moravec (12)
- David Nind (3)
- Séverine QUEUNE (7)
- Martin Renvoize (133)
- Andreas Roussos (1)
- Pierre-Marc Thibault (4)
- Mark Tompsett (2)
- George Veranis (1)


We regret any omissions.  If a contributor has been inadvertently missed,
please send a patch against these release notes to 
koha-patches@lists.koha-community.org.

## Revision control notes

The Koha project uses Git for version control.  The current development 
version of Koha can be retrieved by checking out the master branch of:

- [Koha Git Repository](git://git.koha-community.org/koha.git)

The branch for this version of Koha and future bugfixes in this release
line is 18.05.x.

## Bugs and feature requests

Bug reports and feature requests can be filed at the Koha bug
tracker at:

- [Koha Bugzilla](http://bugs.koha-community.org)

He rau ringa e oti ai.
(Many hands finish the work)

Autogenerated release notes updated last on 23 Oct 2018 15:00:16.
